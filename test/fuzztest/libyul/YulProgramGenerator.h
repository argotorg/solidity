/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
// SPDX-License-Identifier: GPL-3.0

/// Generator of Yul programs for property tests
///
/// The programs address storage and memory through variables that mostly hold small values, so that different
/// locations frequently alias at runtime. They are deterministic, always terminate and only depend on their
/// calldata, so they can be executed by the Yul interpreter and compared across runs.
///
/// Layout of what the programs read and write:
///
///   calldata              4 words of 32 bytes (numCalldataWords), each holding a value from 0 to 4 (below
///                         smallValueBound), read with calldataload(0), calldataload(32), ...
///
///   storage and memory
///     0, 1, 2, ...        the addresses held by locations. A location is a literal or calldata word below
///                         smallValueBound, or a sum or small multiple of other locations; accesses add an
///                         offset of up to 32. Crowded on purpose: locations alias, and a store through one
///                         invalidates what is known about the others.
///
///   storage only
///     100 .. 107          "distant" slots, written as sstore(<literal>, mload(...)). Locations rarely reach them,
///                         so what is known about them survives the stores through locations.
///     2**256 - 3 ..       a location minus 1 to 3, wrapped around below zero
///
/// Limitations:
///   - every function has numFunctionParameters parameters and one return value
///   - every call is a declaration: `let v := f(a, b)`
///   - no calls as statements: `f(a, b)`
///   - no functions with no or several return values: `let x, y := f(a, b)`
///   - no assignments from a call: `v := f(a, b)`
///   - no recursion, at most maxCallsPerFunction calls in a function, and no chain of calls longer than maxCallDepth
///   - a function is only called after its definition
///   - no external calls or creates: `call`, `staticcall`, `delegatecall`, `create`
///   - memory is only written by `mstore`, `mstore8` and `calldatacopy`: no `mcopy`, `codecopy`, `returndatacopy`
///   - no `msize`, `log`, `selfdestruct` or transient storage
///   - loops run at most three iterations, all have the same shape and are only nested through a function that
///     is defined or called in a loop
///   - nesting depth is at most maxNestingDepth
///   - the top level only terminates at its end, or through a call to a function that reverts
///   - every `switch` has the cases 0 and 1 and a default
///   - every variable is declared with a value, one per declaration
///   - memory addresses are always small, only storage slots wrap around to just under 2**256.
///     this is so we don't run out of gas
///   - `keccak256` and `calldatacopy` only use the literal sizes 1, 32, 33 and 64

#pragma once

#include <libsolutil/Common.h>

#include <fuzztest/fuzztest.h>

#include <array>
#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

namespace solidity::yul::test
{

std::size_t constexpr randomBytesPerInstruction = 24; // more than any instruction needs
std::size_t constexpr maxNestingDepth = 3;
std::size_t constexpr maxSmallValueDepth = 2; // how deep the expressions for small values nest

/// New operations also need a row in operationInfos.
enum class Operation: std::uint8_t
{
	DeclareLocation,
	DeclareDerivedLocation,
	Reassign,
	StorageStore,
	MemoryStore,
	MemoryStoreByte,
	CalldataCopy,
	Load,
	Hash,
	MemoryToStorage,
	OpenIf,
	OpenSwitch,
	OpenLoop,
	BreakContinueOrLeave,
	OpenFunction,
	CallFunction
};

struct OperationInfo
{
	Operation operation;
	char const* name;
	/// Percentage of the instructions that are this operation
	std::size_t percent;
};

OperationInfo constexpr operationInfos[] = {
	{Operation::DeclareLocation,        "DeclareLocation",        6},
	{Operation::DeclareDerivedLocation, "DeclareDerivedLocation", 9},
	{Operation::Reassign,               "Reassign",              11},
	{Operation::StorageStore,           "StorageStore",          11},
	{Operation::MemoryStore,            "MemoryStore",            6},
	{Operation::MemoryStoreByte,        "MemoryStoreByte",        3},
	{Operation::CalldataCopy,           "CalldataCopy",           3},
	{Operation::Load,                   "Load",                   6},
	{Operation::Hash,                   "Hash",                   3},
	{Operation::MemoryToStorage,        "MemoryToStorage",        3},
	{Operation::OpenIf,                 "OpenIf",                11},
	{Operation::OpenSwitch,             "OpenSwitch",             5},
	{Operation::OpenLoop,               "OpenLoop",               5},
	{Operation::BreakContinueOrLeave,   "BreakContinueOrLeave",   3},
	{Operation::OpenFunction,           "OpenFunction",           6},
	{Operation::CallFunction,           "CallFunction",           9}
};

std::size_t constexpr numOperations = std::size(operationInfos);

static_assert(
	[] {
		std::size_t sum = 0;
		for (OperationInfo const& info: operationInfos)
			sum += info.percent;
		return sum == 100;
	}(),
	"The percentages of the operation distributions must add up to 100."
);

static_assert(
	[] {
		for (std::size_t i = 0; i < std::size(operationInfos); ++i)
			if (static_cast<std::size_t>(operationInfos[i].operation) != i)
				return false;
		return true;
	}(),
	"Row i of operationInfos must describe the operation with value i: the statistics are indexed by that value."
);

struct Instruction
{
	Operation operation;
	/// Random bytes that decide the operands, consumed through RandomBytes
	std::array<std::uint8_t, randomBytesPerInstruction> randomBytes;
};

/// What the generator produced, summed over the programs it built
struct GeneratorStatistics
{
	std::size_t programs = 0;
	std::size_t lines = 0;
	std::size_t variables = 0;
	std::size_t locationsDeclared = 0;
	std::size_t dataDeclared = 0;
	std::size_t loopCountersDeclared = 0;
	std::size_t bases = 0;
	std::size_t locationsInScope = 0;
	std::size_t dataInScope = 0;
	std::array<std::size_t, maxNestingDepth + 1> programsWithMaxDepth{};
	std::array<std::size_t, numOperations> operations{};
	std::array<std::size_t, numOperations> noOps{};
	std::array<std::size_t, maxNestingDepth + 1> instructionsAtDepth{};
	std::array<std::size_t, maxSmallValueDepth + 1> smallValuesAtDepth{};
	std::size_t functions = 0;
	std::size_t nestedFunctions = 0;
	std::size_t reassignments = 0;
	std::size_t reassignmentsOfBase = 0;
	std::size_t reassignmentsForcedToMentionTarget = 0;
	std::size_t reassignmentsMentioningTarget = 0;
	std::size_t reassignmentsToItself = 0;
	std::size_t storageSlots = 0;
	std::size_t storageSlotsWithSubtraction = 0;

	/// Prints to stderr, if any program was built.
	void print() const;
};


fuzztest::Domain<std::vector<Instruction>> instructionsDomain();

/// Turns a list of instructions into a Yul program, adding to @a _statistics what it produced, if given.
///
/// Locations (v0, v1, ...) address storage and memory, data variables (d0, d1, ...) hold what was loaded.
/// Functions (f0, f1, ...) take numFunctionParameters locations and return one. They are defined in any block,
/// also inside other functions.
/// Example program looks like this:
///
///   {
///       let v0 := 2
///       let v1 := calldataload(0)
///       let v2 := add(v0, 1)
///       sstore(v2, calldataload(64))
///       if eq(v0, calldataload(32)) {
///           v0 := add(v2, 3)
///       }
///       let d3 := sload(sub(v2, 1))
///       mstore(add(v1, 32), d3)
///       return(0, 128)
///   }
std::string buildProgram(
	std::vector<Instruction> const& _instructions,
	GeneratorStatistics* _statistics = nullptr
);

/// The calldata of one run, as the value of each 32-byte word, not as the bytes themselves; toCalldata encodes it.
struct CalldataWords
{
	std::vector<std::uint8_t> values;
};

inline std::vector<std::uint8_t> const& format_as(CalldataWords const& _words) { return _words.values; }

/// Values stay below smallValueBound, so that locations read from calldata collide. In one of eight cases each,
/// all words are zero or all are one: then all such locations alias, and no or every branch on a calldata word is
/// taken.
fuzztest::Domain<CalldataWords> calldataWordsDomain();

/// Encodes each value as one 32-byte calldata word.
bytes toCalldata(CalldataWords const& _words);

}
