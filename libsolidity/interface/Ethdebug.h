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
/// The ethdebug resources of a contract: the type documents and pointer
/// templates of ethdebug/format/info/resources, derived from analysis results.

#pragma once

#include <libsolidity/ast/ASTForward.h>

#include <libevmasm/EthdebugSchema.h>

#include <map>
#include <string>

namespace solidity::frontend::ethdebug
{

/// The two resource tables of ethdebug/format/info/resources.
struct Resources
{
	/// Type documents keyed by the compiler's type identifier. Composed types
	/// reference their component types by that identifier.
	std::map<std::string, evmasm::ethdebug::schema::Type> types;
	/// Pointer templates keyed by layout and canonical type identifier.
	/// Reference types use their declared location; value types have storage,
	/// transient, memory and, when ABI-encodable, calldata templates.
	std::map<std::string, evmasm::ethdebug::schema::Pointer::Template> pointers;

	/// Adds the tables of @a _other. Entries with the same key must serialize identically.
	/// @warning Within a compilation, the key-to-type and key-to-pointer mappings must
	/// be deterministic and independent of the contract that produced the tables.
	void merge(Resources _other);
};

/// The resources of @a _contract: the types of its state variables, including
/// constants and immutables, and of the parameters, return variables and locals
/// of functions and modifiers in its creation and deployed call graphs.
/// Their parameter and non-empty return lists also contribute tuple documents.
/// Pointer templates describe the layouts of those variable types, including
/// their component types. They do not locate individual variable instances.
/// @a _sourceIndices maps source unit names to the source IDs of the ethdebug
/// compilation record, which definition locations refer to.
Resources resources(ContractDefinition const& _contract, std::map<std::string, unsigned> const& _sourceIndices);

}
