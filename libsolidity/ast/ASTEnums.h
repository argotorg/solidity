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
/**
 * @date 2017
 * Enums for AST classes.
 */

#pragma once

#include <liblangutil/Exceptions.h>
#include <libsolidity/ast/ASTForward.h>

#include <string>

namespace solidity::frontend
{

/// Possible lookups for function resolving
enum class VirtualLookup { Static, Virtual, Super };

// How a function can mutate the EVM state.
enum class StateMutability { Pure, View, NonPayable, Payable };

/// @param _stateMutability The state mutability string to convert.
/// @return The corresponding StateMutability enum value.
inline StateMutability stateMutabilityFromString(std::string const& _stateMutability)
{
	if (_stateMutability == "pure")
		return StateMutability::Pure;
	else if (_stateMutability == "view")
		return StateMutability::View;
	else if (_stateMutability == "nonpayable")
		return StateMutability::NonPayable;
	else if (_stateMutability == "payable")
		return StateMutability::Payable;
	else
		solAssert(false, "Unknown state mutability \"" + _stateMutability + "\"");
}

/// @param _stateMutability The state mutability enum value to convert to string.
/// @return The string representation of the state mutability.
inline std::string stateMutabilityToString(StateMutability const& _stateMutability)
{
	switch (_stateMutability)
	{
	case StateMutability::Pure:
		return "pure";
	case StateMutability::View:
		return "view";
	case StateMutability::NonPayable:
		return "nonpayable";
	case StateMutability::Payable:
		return "payable";
	default:
		solAssert(false, "Unknown state mutability.");
	}
}

/// Visibility ordered from restricted to unrestricted.
enum class Visibility { Default, Private, Internal, Public, External };

enum class Arithmetic { Checked, Wrapping };

class Type;

/// Container for function call parameter types & names
struct FuncCallArguments
{
	/// Types of arguments
	std::vector<Type const*> types;
	/// Names of the arguments if given, otherwise unset
	std::vector<ASTPointer<ASTString>> names;

	size_t numArguments() const { return types.size(); }
	size_t numNames() const { return names.size(); }
	bool hasNamedArguments() const { return !names.empty(); }
};

enum class ContractKind { Interface, Contract, Library };

}
