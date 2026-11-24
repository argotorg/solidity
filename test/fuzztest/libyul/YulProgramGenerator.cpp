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

#include <test/fuzztest/libyul/YulProgramGenerator.h>

#include <libsolutil/Assertions.h>
#include <libsolutil/CommonData.h>
#include <libsolutil/StringUtils.h>
#include <libyul/Exceptions.h>

#include <fmt/format.h>

#include <range/v3/algorithm/any_of.hpp>
#include <range/v3/range/conversion.hpp>
#include <range/v3/view/filter.hpp>

#include <algorithm>
#include <array>
#include <cstdio>
#include <limits>
#include <set>
#include <utility>

namespace solidity::yul::test
{

namespace
{

std::size_t constexpr minInstructions = 16; // FuzzTest starts out with vectors of minimal size
std::size_t constexpr maxInstructions = 96;
std::size_t constexpr numFunctionParameters = 2;
std::size_t constexpr maxCaseLength = 3; // instructions in one case of a switch
std::size_t constexpr maxCallDepth = 2; // a function calls a function that calls a function
std::size_t constexpr maxCallsPerFunction = 2;

std::uint8_t constexpr smallValueBound = 5; // exclusive bound of literals and calldata words, so locations collide
std::size_t constexpr numCalldataWords = 4;
std::size_t constexpr distantSlotsStart = 100; // first of a few storage slots the locations rarely reach
std::size_t constexpr numDistantSlots = 8;
std::size_t constexpr returnedMemorySize = 128; // the final return keeps the stores to memory below this alive

static_assert(
	minInstructions <= maxInstructions,
	"The range of program sizes must not be empty."
);
// Each instruction declares at most one location or data variable, on top of the three initial locations.
static_assert(3 + maxInstructions <= 256, "The variables in scope must stay pickable from a single random byte.");
static_assert(smallValueBound > 1, "The fixed input (calldata) with every word being constant 1 must stay within the range of small values.");

/// NaN when there is nothing to divide by: fmt prints it as "nan", padded like any number.
double ratio(std::size_t const _part, std::size_t const _total)
{
	if (_total == 0)
		return std::numeric_limits<double>::quiet_NaN();
	return static_cast<double>(_part) / static_cast<double>(_total);
}

/// Hands out the random bytes of an instruction one by one.
class RandomBytes
{
public:
	explicit RandomBytes(Instruction const& _instruction): m_bytes(_instruction.randomBytes) {}

	/// @returns a number below @a _count.
	/// Draw into named variables: the evaluation order of function arguments is unspecified.
	std::uint8_t pick(std::size_t const _count)
	{
		yulAssert(_count > 0 && _count <= 256, "pick draws from a single byte");
		yulAssert(m_next < m_bytes.size(), "Instruction used up its random bytes: raise randomBytesPerInstruction.");
		return m_bytes[m_next++] % _count;
	}

private:
	std::array<std::uint8_t, randomBytesPerInstruction> const& m_bytes;
	std::size_t m_next = 0;
};

class ProgramBuilder
{
public:
	ProgramBuilder(GeneratorStatistics& _statistics):
		m_statistics(_statistics)
	{}

	std::string build(std::vector<Instruction> const& _instructions)
	{
		if (!_instructions.empty())
			declareInitialLocations(_instructions.front());
		for (Instruction const& instruction: _instructions)
			add(instruction);
		while (!m_openStatements.empty())
			closeBody();
		// Keeps memory stores alive. As a statement, it is also a place to check what holds once the program is done.
		m_code += fmt::format("return(0, {})\n", returnedMemorySize);
		++m_statistics.programs;
		m_statistics.lines += static_cast<std::size_t>(std::count(m_code.begin(), m_code.end(), '\n'));
		m_statistics.variables += m_nextVariableIndex;
		m_statistics.bases += m_bases.size();
		++m_statistics.programsWithMaxDepth[m_maxDepth];
		return "{\n" + m_code + "}\n";
	}

private:
	/// A braced block: the body of an if, loop or function, or of one case of a switch.
	struct Body
	{
		std::string opening;
		std::string closing;
		std::size_t numInstructions;
	};

	enum class CompoundStatementKind { If, Switch, Loop, Function };

	/// An if, switch, for loop or function definition that is open: its bodies are being generated.
	struct CompoundStatement
	{
		CompoundStatementKind kind;
		/// The open body, followed by those still to open: the remaining cases of a switch.
		std::vector<Body> bodies;
		/// Instructions still to add before the open body closes
		std::size_t remainingInstructions = 0;
		/// Sizes of m_locations and m_data when the statement was opened, restored when a body closes.
		std::size_t numLocations = 0;
		std::size_t numData = 0;
		/// Size of m_functions when the statement was opened: the functions defined in a body end with it.
		std::size_t numFunctions = 0;
	};

	struct Function
	{
		std::size_t index;
		/// Length of the longest chain of calls starting in the function
		std::size_t callDepth;
	};

	struct FunctionFrame
	{
		/// The variables of the code around the function, which the function cannot access
		std::vector<std::string> outerLocations;
		std::vector<std::string> outerData;
		std::size_t index = 0;
		std::size_t callDepth = 0;
		std::size_t numCalls = 0;
	};

	void add(Instruction const& _instruction)
	{
		RandomBytes randomBytes{_instruction};
		std::size_t const depth = m_openStatements.size();
		std::size_t const operationIndex = static_cast<std::size_t>(_instruction.operation);
		std::size_t const codeSizeBefore = m_code.size();
		++m_statistics.operations[operationIndex];
		++m_statistics.instructionsAtDepth[depth];
		m_statistics.locationsInScope += m_locations.size();
		m_statistics.dataInScope += m_data.size();
		switch (_instruction.operation)
		{
		case Operation::DeclareLocation:
			declareLocation(smallValue(randomBytes));
			break;
		case Operation::DeclareDerivedLocation:
			declareDerivedLocation(randomBytes);
			break;
		case Operation::Reassign:
			reassign(randomBytes);
			break;
		case Operation::StorageStore:
			store("sstore", storageSlot(randomBytes), randomBytes);
			break;
		case Operation::MemoryStore:
			store("mstore", accessAddress(randomBytes), randomBytes);
			break;
		case Operation::MemoryStoreByte:
			store("mstore8", accessAddress(randomBytes), randomBytes);
			break;
		case Operation::CalldataCopy:
		{
			std::string const target = accessAddress(randomBytes);
			std::string const source = calldataOffset(randomBytes);
			m_code += fmt::format("calldatacopy({}, {}, {})\n", target, source, rangeSize(randomBytes));
			break;
		}
		case Operation::Load:
		{
			if (randomBytes.pick(2) == 0)
				declareData(fmt::format("mload({})", accessAddress(randomBytes)));
			else
				declareData(fmt::format("sload({})", storageSlot(randomBytes)));
			break;
		}
		case Operation::Hash:
		{
			std::string const start = accessAddress(randomBytes);
			declareData(fmt::format("keccak256({}, {})", start, rangeSize(randomBytes)));
			break;
		}
		case Operation::MemoryToStorage:
		{
			std::size_t const slot = distantSlotsStart + randomBytes.pick(numDistantSlots);
			m_code += fmt::format("sstore({}, mload({}))\n", slot, accessAddress(randomBytes));
			break;
		}
		case Operation::OpenIf:
			openIf(randomBytes);
			break;
		case Operation::OpenSwitch:
			openSwitch(randomBytes);
			break;
		case Operation::OpenLoop:
			openLoop(randomBytes);
			break;
		case Operation::BreakContinueOrLeave:
		{
			std::vector<std::string> jumps;
			if (insideLoop())
				jumps = {"continue", "break"};
			if (insideFunction())
				jumps.push_back("leave");
			if (!jumps.empty())
			{
				std::string const jump = jumps[randomBytes.pick(jumps.size())];
				m_code += fmt::format("if {} {{ {} }}\n", condition(randomBytes), jump);
			}
			else
				// Not valid outside a loop or function. Reassigns instead, which invalidates what the analyzer knows
				// about the variable and everything derived from it.
				reassign(randomBytes);
			break;
		}
		case Operation::OpenFunction:
			openFunction(randomBytes);
			break;
		case Operation::CallFunction:
			callFunction(randomBytes);
			break;
		}
		if (m_code.size() == codeSizeBefore)
			++m_statistics.noOps[operationIndex];
		// An instruction that opened a compound statement is only complete once that statement is closed.
		if (m_openStatements.size() == depth)
			completeInstruction();
	}

	/// Top-level locations, one of them derived, so that every instruction has some in scope.
	void declareInitialLocations(Instruction const& _instruction)
	{
		RandomBytes randomBytes{_instruction};
		declareLocation(randomBytes.pick(2) == 0 ? smallLiteral(randomBytes) : calldataWord(randomBytes));
		declareLocation(smallValue(randomBytes));
		declareDerivedLocation(randomBytes);
	}

	void declareLocation(std::string const& _value)
	{
		m_locations.push_back(fmt::format("v{}", m_nextVariableIndex++));
		++m_statistics.locationsDeclared;
		m_code += fmt::format("let {} := {}\n", m_locations.back(), _value);
	}

	/// Declares a location equal to, or at a constant offset from, an existing location, its base.
	void declareDerivedLocation(RandomBytes& _randomBytes)
	{
		// Without a location to derive from, declares an independent one, so that the instruction is not wasted.
		if (m_locations.empty())
		{
			declareLocation(smallValue(_randomBytes));
			return;
		}

		std::string const base = pickLocation(_randomBytes);
		m_bases.insert(base);
		std::vector<std::string> const forms{
			base,
			fmt::format("add({}, 0)", base),
			fmt::format("sub({}, 0)", base),
			fmt::format("add({}, {})", base, 1 + _randomBytes.pick(3))
		};
		declareLocation(forms[_randomBytes.pick(forms.size())]);
	}

	void declareData(std::string const& _value)
	{
		m_data.push_back(fmt::format("d{}", m_nextVariableIndex++));
		++m_statistics.dataDeclared;
		m_code += fmt::format("let {} := {}\n", m_data.back(), _value);
	}

	void reassign(RandomBytes& _randomBytes)
	{
		if (m_locations.empty())
			return;
		std::string const target = reassignmentTarget(_randomBytes);
		m_pickedLocations.clear();
		// A value mentioning the target leaves the analyzer without a value for it, even after the expression splitter.
		// A change from one unknown value to another is easy to miss.
		bool const selfReferencing = _randomBytes.pick(3) == 0;
		std::string const value =
			selfReferencing ?
			fmt::format("add({}, {})", target, smallValue(_randomBytes, maxSmallValueDepth)) :
			smallValue(_randomBytes);
		m_statistics.reassignmentsForcedToMentionTarget += selfReferencing ? 1 : 0;
		++m_statistics.reassignments;
		m_statistics.reassignmentsOfBase += m_bases.count(target);
		m_statistics.reassignmentsMentioningTarget += m_pickedLocations.count(target);
		m_statistics.reassignmentsToItself += value == target ? 1 : 0;
		m_code += fmt::format("{} := {}\n", target, value);
	}

	void store(char const* _builtin, std::string const& _address, RandomBytes& _randomBytes)
	{
		m_code += fmt::format("{}({}, {})\n", _builtin, _address, storedValue(_randomBytes));
	}

	/// Mostly short, so that code after the statement is common; sometimes long enough for a real loop body.
	std::size_t bodyLength(RandomBytes& _randomBytes) const
	{
		static std::size_t constexpr lengths[] = {1, 1, 2, 2, 2, 3, 3, 5};
		return lengths[_randomBytes.pick(std::size(lengths))];
	}

	std::size_t caseLength(RandomBytes& _randomBytes) const { return 1 + _randomBytes.pick(maxCaseLength); }

	/// Opens a compound statement made of the given bodies, one after the other. Does nothing at the maximum nesting
	/// depth.
	void openStatement(CompoundStatementKind const _kind, std::vector<Body> _bodies)
	{
		if (m_openStatements.size() >= maxNestingDepth)
			return;
		m_openStatements.push_back(CompoundStatement{
			.kind = _kind,
			.bodies = std::move(_bodies),
			.numLocations = m_locations.size(),
			.numData = m_data.size(),
			.numFunctions = m_functions.size()
		});
		m_maxDepth = std::max(m_maxDepth, m_openStatements.size());
		openBody();
	}

	void openBody()
	{
		CompoundStatement& statement = m_openStatements.back();
		yulAssert(statement.bodies.front().numInstructions > 0, "An empty body would never close.");
		m_code += statement.bodies.front().opening;
		statement.remainingInstructions = statement.bodies.front().numInstructions;
	}

	void openIf(RandomBytes& _randomBytes)
	{
		openStatement(CompoundStatementKind::If, {Body{
			.opening = fmt::format("if {} {{\n", condition(_randomBytes)),
			.closing = "}\n",
			.numInstructions = bodyLength(_randomBytes)
		}});
	}

	/// The bodies of the cases are short, so that a switch does not use up much more of the program than an if.
	void openSwitch(RandomBytes& _randomBytes)
	{
		std::vector<Body> cases;
		cases.push_back(Body{
			.opening = fmt::format("switch {} case 0 {{\n", smallValue(_randomBytes)),
			.closing = "}\n",
			.numInstructions = caseLength(_randomBytes)
		});
		cases.push_back(Body{.opening = "case 1 {\n", .closing = "}\n", .numInstructions = caseLength(_randomBytes)});
		cases.push_back(Body{.opening = "default {\n", .closing = "}\n", .numInstructions = caseLength(_randomBytes)});
		openStatement(CompoundStatementKind::Switch, std::move(cases));
	}

	/// Opens a loop of up to three iterations. Loops are not nested directly, which keeps executions short.
	void openLoop(RandomBytes& _randomBytes)
	{
		// Opens an if instead, so that the instruction is not wasted.
		if (insideLoop())
		{
			openIf(_randomBytes);
			return;
		}

		std::string const counter = fmt::format("i{}", m_nextVariableIndex++);
		++m_statistics.loopCountersDeclared;
		std::string const bound = calldataWord(_randomBytes);
		openStatement(
			CompoundStatementKind::Loop,
			{Body{
				.opening = fmt::format(
					"for {{ let {0} := 0 }} lt({0}, and({1}, 3)) {{ {0} := add({0}, 1) }} {{\n",
					counter,
					bound
				),
				.closing = "}\n",
				.numInstructions = bodyLength(_randomBytes)
			}}
		);
	}

	/// Opens a function in the current block, so that the rest of that block can call it. Its parameters and its
	/// return variable are its locations: it cannot access the variables declared outside.
	void openFunction(RandomBytes& _randomBytes)
	{
		if (m_openStatements.size() >= maxNestingDepth)
			return;

		std::vector<std::string> parameters;
		for (std::size_t i = 0; i < numFunctionParameters; ++i)
			parameters.push_back(fmt::format("v{}", m_nextVariableIndex++));
		std::string const returnVariable = fmt::format("v{}", m_nextVariableIndex++);

		m_statistics.locationsDeclared += parameters.size() + 1;
		// One function in eight never returns to its caller.
		std::string const closing = _randomBytes.pick(8) == 0 ? "revert(0, 0)\n}\n" : "}\n";
		std::size_t const numInstructions = 2 * bodyLength(_randomBytes);
		FunctionFrame frame{.index = m_numFunctions++};
		m_code += fmt::format(
			"function f{}({}) -> {} ",
			frame.index,
			util::joinHumanReadable(parameters),
			returnVariable
		);
		frame.outerLocations = std::exchange(m_locations, std::move(parameters));
		m_locations.push_back(returnVariable);
		frame.outerData = std::exchange(m_data, {});
		++m_statistics.functions;
		m_statistics.nestedFunctions += m_openStatements.empty() ? 0 : 1;
		openStatement(
			CompoundStatementKind::Function,
			{Body{.opening = "{\n", .closing = closing, .numInstructions = numInstructions}}
		);
		m_functionFrames.push_back(std::move(frame));
	}

	/// A function makes at most maxCallsPerFunction calls, and no chain of calls is longer than maxCallDepth
	bool callableFromFunction(Function const& _function) const
	{
		return m_functionFrames.back().numCalls < maxCallsPerFunction && _function.callDepth < maxCallDepth;
	}

	/// Calls a function that is complete and in scope.
	void callFunction(RandomBytes& _randomBytes)
	{
		std::vector<Function> callable;
		for (Function const& function: m_functions)
			if (!insideFunction() || callableFromFunction(function))
				callable.push_back(function);
		// Without a function to call, reassigns a location instead, so that the instruction is not wasted.
		if (callable.empty())
		{
			reassign(_randomBytes);
			return;
		}

		Function const function = callable[_randomBytes.pick(callable.size())];
		std::vector<std::string> arguments;
		for (std::size_t i = 0; i < numFunctionParameters; ++i)
			arguments.push_back(smallValue(_randomBytes));
		declareLocation(fmt::format("f{}({})", function.index, util::joinHumanReadable(arguments)));
		if (insideFunction())
		{
			++m_functionFrames.back().numCalls;
			noteCall(function);
		}
	}

	void noteCall(Function const& _function)
	{
		FunctionFrame& frame = m_functionFrames.back();
		frame.callDepth = std::max(frame.callDepth, _function.callDepth + 1);
	}

	/// A loop around the function being built does not count: break and continue cannot leave a function.
	bool insideLoop() const
	{
		for (
			auto statement = m_openStatements.rbegin();
			statement != m_openStatements.rend() && statement->kind != CompoundStatementKind::Function;
			++statement
		)
			if (statement->kind == CompoundStatementKind::Loop)
				return true;
		return false;
	}
	bool insideFunction() const { return !m_functionFrames.empty(); }

	void completeInstruction()
	{
		while (!m_openStatements.empty() && --m_openStatements.back().remainingInstructions == 0)
			if (!closeBody())
				break;
	}

	/// @returns false if that opened the next case of a switch, true if the whole statement is closed.
	bool closeBody()
	{
		CompoundStatement& statement = m_openStatements.back();
		m_code += statement.bodies.front().closing;
		statement.bodies.erase(statement.bodies.begin());
		yulAssert(
			m_locations.size() >= statement.numLocations &&
			m_data.size() >= statement.numData &&
			m_functions.size() >= statement.numFunctions,
			"What was in scope when the body opened must still be in scope when it closes."
		);
		m_locations.resize(statement.numLocations);
		m_data.resize(statement.numData);
		m_functions.resize(statement.numFunctions);
		if (!statement.bodies.empty())
		{
			openBody();
			return false;
		}
		CompoundStatementKind const kind = statement.kind;
		m_openStatements.pop_back();
		if (kind == CompoundStatementKind::Function)
		{
			FunctionFrame frame = std::move(m_functionFrames.back());
			m_functionFrames.pop_back();
			m_locations = std::move(frame.outerLocations);
			m_data = std::move(frame.outerData);
			m_functions.push_back(Function{.index = frame.index, .callDepth = frame.callDepth});
		}
		return true;
	}

	std::string smallLiteral(RandomBytes& _randomBytes) const
	{
		return std::to_string(_randomBytes.pick(smallValueBound));
	}

	std::string calldataOffset(RandomBytes& _randomBytes) const
	{
		return std::to_string(32 * _randomBytes.pick(numCalldataWords));
	}

	std::string calldataWord(RandomBytes& _randomBytes) const
	{
		return fmt::format("calldataload({})", calldataOffset(_randomBytes));
	}

	/// Range sizes: under a word, one word, just over a word, two words.
	std::size_t rangeSize(RandomBytes& _randomBytes) const
	{
		static std::size_t constexpr sizes[] = {1, 32, 33, 64};
		return sizes[_randomBytes.pick(std::size(sizes))];
	}

	/// Requires a declared location. Mostly picks among the four newest, which are likelier to be related.
	std::string pickLocation(RandomBytes& _randomBytes)
	{
		std::size_t const candidates =
			_randomBytes.pick(10) < 7 ? std::min<std::size_t>(m_locations.size(), 4) : m_locations.size();
		std::string const& location = m_locations[m_locations.size() - 1 - _randomBytes.pick(candidates)];
		m_pickedLocations.insert(location);
		return location;
	}

	/// Mostly picks a base: reassigning one invalidates what is known about locations derived from it.
	std::string reassignmentTarget(RandomBytes& _randomBytes)
	{
		std::vector<std::string> const bases =
			m_locations |
			ranges::views::filter([&](std::string const& _location) { return m_bases.contains(_location); }) |
			ranges::to<std::vector>;
		if (!bases.empty() && _randomBytes.pick(10) < 7)
			return bases[_randomBytes.pick(bases.size())];
		return pickLocation(_randomBytes);
	}

	/// An expression that evaluates to a small value, nested up to maxSmallValueDepth levels deep.
	std::string smallValue(RandomBytes& _randomBytes, std::size_t const _depth = 0)
	{
		// Up to Location, the forms do not nest: they are the only ones at the maximum depth.
		enum class Form
		{
			Literal,
			CalldataWord,
			Location,
			LocationPlusValue,
			ValuePlusLiteral,
			ValueTimesLiteral,
			MaskedLoad
		};
		auto const numFormsUpTo = [](Form const _form) { return static_cast<std::size_t>(_form) + 1; };
		++m_statistics.smallValuesAtDepth[_depth];
		Form const lastForm = _depth < maxSmallValueDepth ? Form::MaskedLoad : Form::Location;
		Form const form = static_cast<Form>(_randomBytes.pick(numFormsUpTo(lastForm)));
		if (m_locations.empty())
			return smallLiteral(_randomBytes);
		switch (form)
		{
		case Form::Literal:
			return smallLiteral(_randomBytes);
		case Form::CalldataWord:
			return calldataWord(_randomBytes);
		case Form::Location:
			return pickLocation(_randomBytes);
		case Form::LocationPlusValue:
		{
			std::string const location = pickLocation(_randomBytes);
			return fmt::format("add({}, {})", location, smallValue(_randomBytes, _depth + 1));
		}
		case Form::ValuePlusLiteral:
		{
			std::string const operand = smallValue(_randomBytes, _depth + 1);
			return fmt::format("add({}, {})", operand, 1 + _randomBytes.pick(3));
		}
		case Form::ValueTimesLiteral:
		{
			std::string const operand = smallValue(_randomBytes, _depth + 1);
			return fmt::format("mul({}, {})", operand, 1 + _randomBytes.pick(2));
		}
		case Form::MaskedLoad:
			return fmt::format("and(sload({}), 7)", smallValue(_randomBytes, _depth + 1));
		}
		util::unreachable();
	}

	/// A small value plus an offset that makes memory accesses overlap partially (1 to 3) or not at all (32).
	std::string accessAddress(RandomBytes& _randomBytes)
	{
		static std::uint8_t constexpr offsets[] = {0, 0, 1, 2, 3, 32};
		std::string const base = smallValue(_randomBytes);
		std::uint8_t const offset = offsets[_randomBytes.pick(std::size(offsets))];
		return offset == 0 ? base : fmt::format("add({}, {})", base, offset);
	}

	/// An access address, sometimes lowered by 1 to 3: below zero it wraps around to just under 2**256.
	/// Only for storage, as the interpreter does not model memory that high.
	std::string storageSlot(RandomBytes& _randomBytes)
	{
		static std::uint8_t constexpr distances[] = {0, 0, 0, 0, 0, 1, 2, 3};
		std::string const address = accessAddress(_randomBytes);
		std::uint8_t const distance = distances[_randomBytes.pick(std::size(distances))];
		++m_statistics.storageSlots;
		m_statistics.storageSlotsWithSubtraction += distance == 0 ? 0 : 1;
		return distance == 0 ? address : fmt::format("sub({}, {})", address, distance);
	}

	std::string storedValue(RandomBytes& _randomBytes)
	{
		enum class Form { Variable, StorageLoad, MemoryLoad, SmallValue };
		switch (static_cast<Form>(_randomBytes.pick(static_cast<std::size_t>(Form::SmallValue) + 1)))
		{
		case Form::Variable:
		{
			std::size_t const numCandidates = m_data.size() + m_locations.size();
			if (numCandidates == 0)
				return smallValue(_randomBytes);
			std::size_t const index = _randomBytes.pick(numCandidates);
			return index < m_data.size() ? m_data[index] : m_locations[index - m_data.size()];
		}
		case Form::StorageLoad:
			return fmt::format("sload({})", storageSlot(_randomBytes));
		case Form::MemoryLoad:
			return fmt::format("mload({})", accessAddress(_randomBytes));
		case Form::SmallValue:
			return smallValue(_randomBytes);
		}
		util::unreachable();
	}

	std::string condition(RandomBytes& _randomBytes)
	{
		std::size_t const form = _randomBytes.pick(3);
		if (form == 0 || (form == 1 && m_locations.empty()))
			return calldataWord(_randomBytes);
		std::string const left = form == 1 ? pickLocation(_randomBytes) : smallValue(_randomBytes);
		std::string const right = smallValue(_randomBytes);
		return fmt::format("{}({}, {})", form == 1 ? "eq" : "lt", left, right);
	}

	std::string m_code;
	std::vector<CompoundStatement> m_openStatements;
	/// Variables in scope that mostly hold small values and address storage and memory (v0, v1, ...)
	std::vector<std::string> m_locations;
	/// Variables in scope that hold loaded values of any size (d0, d1, ...)
	std::vector<std::string> m_data;
	/// Locations other locations were derived from, in scope or not
	std::set<std::string> m_bases;
	/// Locations picked since reassign cleared it, for the statistics
	std::set<std::string> m_pickedLocations;
	GeneratorStatistics& m_statistics;
	/// The complete functions in scope
	std::vector<Function> m_functions;
	/// The functions being built, the innermost last
	std::vector<FunctionFrame> m_functionFrames;
	/// Number of functions opened so far (f0, f1, ...)
	std::size_t m_numFunctions = 0;
	std::size_t m_nextVariableIndex = 0;
	std::size_t m_maxDepth = 0;
};

}

void GeneratorStatistics::print() const
{
	if (programs == 0)
		return;
	std::size_t instructions = 0;
	std::size_t depthSum = 0;
	for (std::size_t depth = 0; depth < instructionsAtDepth.size(); ++depth)
	{
		instructions += instructionsAtDepth[depth];
		depthSum += depth * instructionsAtDepth[depth];
	}
	fmt::print(stderr, "\n== generator statistics ==\n");
	fmt::print(stderr, "programs: {}\n", programs);
	fmt::print(
		stderr,
		"per program: {:.1f} instructions, {:.1f} lines, {:.1f} variables\n",
		ratio(instructions, programs),
		ratio(lines, programs),
		ratio(variables, programs)
	);
	fmt::print(
		stderr,
		"declared per program: {:.1f} locations (v), {:.1f} data variables (d), {:.1f} loop counters (i); "
		"{:.1f} locations used as a base\n",
		ratio(locationsDeclared, programs),
		ratio(dataDeclared, programs),
		ratio(loopCountersDeclared, programs),
		ratio(bases, programs)
	);
	fmt::print(
		stderr,
		"in scope at an instruction, on average: {:.1f} locations, {:.1f} data variables\n",
		ratio(locationsInScope, instructions),
		ratio(dataInScope, instructions)
	);
	fmt::print(stderr, "nesting depth of instructions: average {:.2f}", ratio(depthSum, instructions));
	for (std::size_t depth = 0; depth < instructionsAtDepth.size(); ++depth)
		fmt::print(stderr, ", depth {}: {:.1f}%", depth, 100 * ratio(instructionsAtDepth[depth], instructions));
	std::size_t maxDepthSum = 0;
	for (std::size_t depth = 0; depth < programsWithMaxDepth.size(); ++depth)
		maxDepthSum += depth * programsWithMaxDepth[depth];
	fmt::print(stderr, "\ndeepest nesting of a program: average {:.2f}", ratio(maxDepthSum, programs));
	for (std::size_t depth = 0; depth < programsWithMaxDepth.size(); ++depth)
		fmt::print(stderr, ", depth {}: {:.1f}%", depth, 100 * ratio(programsWithMaxDepth[depth], programs));
	fmt::print(
		stderr,
		"\n\n{:<24}{:>10}{:>9}{:>21}{:>21}\n",
		"operation",
		"drawn",
		"share",
		"of which no effect",
		"emitted per program"
	);
	for (std::size_t operation = 0; operation < operations.size(); ++operation)
		fmt::print(
			stderr,
			"{:<24}{:>10}{:>8.1f}%{:>20.1f}%{:>21.2f}\n",
			operationInfos[operation].name,
			operations[operation],
			100 * ratio(operations[operation], instructions),
			100 * ratio(noOps[operation], operations[operation]),
			ratio(operations[operation] - noOps[operation], programs)
		);
	fmt::print(
		stderr,
		"\nfunctions: {}, not in the outermost block: {:.1f}%\n",
		functions,
		100 * ratio(nestedFunctions, functions)
	);
	fmt::print(
		stderr,
		"reassignments emitted: {}, of a base: {:.1f}%, forced to mention the target: {:.1f}%, "
		"value mentions the target: {:.1f}%, value is the target: {:.1f}%\n",
		reassignments,
		100 * ratio(reassignmentsOfBase, reassignments),
		100 * ratio(reassignmentsForcedToMentionTarget, reassignments),
		100 * ratio(reassignmentsMentioningTarget, reassignments),
		100 * ratio(reassignmentsToItself, reassignments)
	);
	fmt::print(
		stderr,
		"storage addresses: {}, with a subtraction: {:.1f}%\n",
		storageSlots,
		100 * ratio(storageSlotsWithSubtraction, storageSlots)
	);
	std::size_t smallValues = 0;
	for (std::size_t const count: smallValuesAtDepth)
		smallValues += count;
	fmt::print(stderr, "small values: {}", smallValues);
	for (std::size_t depth = 0; depth < smallValuesAtDepth.size(); ++depth)
		fmt::print(stderr, ", nested {} deep: {:.1f}%", depth, 100 * ratio(smallValuesAtDepth[depth], smallValues));
	fmt::print(stderr, "\n");
}

fuzztest::Domain<std::vector<Instruction>> instructionsDomain()
{
	std::vector<Operation> operations;
	for (OperationInfo const& info: operationInfos)
		operations.insert(
			operations.end(),
			info.percent,
			info.operation
		);
	return fuzztest::VectorOf(
		fuzztest::StructOf<Instruction>(
			fuzztest::ElementOf(operations),
			fuzztest::Arbitrary<std::array<std::uint8_t, randomBytesPerInstruction>>()
		)
	).WithMinSize(minInstructions).WithMaxSize(maxInstructions);
}

std::string buildProgram(
	std::vector<Instruction> const& _instructions,
	GeneratorStatistics* const _statistics
)
{
	GeneratorStatistics unused;
	return ProgramBuilder{_statistics ? *_statistics : unused}.build(_instructions);
}

bytes toCalldata(CalldataWords const& _words)
{
	bytes calldata;
	for (std::uint8_t const word: _words.values)
	{
		calldata += bytes(31, 0);
		calldata.push_back(word);
	}
	return calldata;
}

fuzztest::Domain<CalldataWords> calldataWordsDomain()
{
	auto const randomWords = [] {
		return fuzztest::StructOf<CalldataWords>(
			fuzztest::VectorOf(fuzztest::InRange<std::uint8_t>(0, smallValueBound - 1)).WithSize(numCalldataWords)
		);
	};
	return fuzztest::OneOf(
		randomWords(), randomWords(), randomWords(), randomWords(), randomWords(), randomWords(),
		fuzztest::Just(CalldataWords{std::vector<std::uint8_t>(numCalldataWords, 0)}),
		fuzztest::Just(CalldataWords{std::vector<std::uint8_t>(numCalldataWords, 1)})
	);
}

}
