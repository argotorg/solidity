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

#pragma once

#include <libyul/backends/evm/AbstractAssembly.h>

#include <libyul/Dialect.h>
#include <libyul/Scope.h>

#include <bitset>
#include <cstddef>
#include <map>
#include <optional>
#include <tuple>
#include <vector>

namespace solidity::yul
{

class Object;

/// Context used during code generation.
struct BuiltinContext
{
	Object const* currentObject = nullptr;
	/// Mapping from named objects to abstract assembly sub IDs.
	std::map<std::string, AbstractAssembly::SubID> subIDs;

	std::map<Scope::Function const*, AbstractAssembly::FunctionID> functionIDs;
};

struct BuiltinFunctionForEVM: public BuiltinFunction
{
	std::optional<evmasm::Instruction> instruction;
	/// Function to generate code for the given function call and append it to the abstract
	/// assembly. Expects all non-literal arguments of the call to be on stack in reverse order
	/// (i.e. right-most argument pushed first).
	/// Expects the caller to set the source location.
	std::function<void(FunctionCall const&, AbstractAssembly&, BuiltinContext&)> generateCode;
};

/// Collection of all possible EVM builtin functions.
/// Each builtin can have one (or multiple) scopes, which define whether, e.g., it requires object access.
/// Using this class as single source of truth for builtin functions makes sure that these are consistent over
/// EVM dialects. If the order were to depend on the EVM dialect - which can easily happen using conditionals -,
/// different dialects' builtin handles become inherently incompatible.
class EVMBuiltins
{
	static std::size_t constexpr instructionBit = 0;
	static std::size_t constexpr replacedInstructionBit = 1;
	static std::size_t constexpr objectAccessBit = 2;
	static std::size_t constexpr requiresEOFBit = 3;
	static std::size_t constexpr requiresNonEOFBit = 4;

public:
	struct Scopes
	{
		/// whether the corresponding evm builtin function is an instruction builtin
		bool instruction() const { return value.test(instructionBit); }
		/// whether the corresponding evm builtin has been replaced by another builtin, ie, should be skipped
		bool replaced() const { return value.test(replacedInstructionBit); }
		/// if true, the evm builtin function is only valid when object access is given
		bool requiresObjectAccess() const { return value.test(objectAccessBit); }
		/// if true, the evm builtin function is only valid if EOF is enabled
		bool requiresEOF() const { return value.test(requiresEOFBit); }
		/// if true, the evm builtin function is only valid if EOF is not enabled
		bool requiresNonEOF() const { return value.test(requiresNonEOFBit); }

		Scopes operator|(Scopes const& _other) const
		{
			Scopes result = *this;
			result |= _other;
			return result;
		}

		Scopes& operator|=(Scopes const& _other)
		{
			value |= _other.value;
			return *this;
		}

		std::bitset<5> value;
	};

	EVMBuiltins();

	std::vector<std::tuple<Scopes, BuiltinFunctionForEVM>> const& functions() const { return m_scopesAndFunctions; }

	/// Creates a verbatim builtin function. These are not part of the usual builtin functions collection and
	/// must be cached in the dialect creating them.
	static BuiltinFunctionForEVM createVerbatimFunction(size_t _arguments, size_t _returnVariables);
	static SideEffects sideEffectsOfInstruction(evmasm::Instruction _instruction);

private:
	static Scopes constexpr instruction{1 << instructionBit};
	static Scopes constexpr replaced{1 << replacedInstructionBit};
	static Scopes constexpr objectAccess{1 << objectAccessBit};
	static Scopes constexpr requiresEOF{1 << requiresEOFBit};
	static Scopes constexpr requiresNonEOF{1 << requiresNonEOFBit};

	std::vector<std::tuple<Scopes, BuiltinFunctionForEVM>> m_scopesAndFunctions;
};

}
