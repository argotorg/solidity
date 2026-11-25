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

#include <liblangutil/EthdebugSchema.h>
#include <liblangutil/SemanticDebugData.h>
#include <liblangutil/SemanticDebugDataTable.h>

#include <map>
#include <optional>
#include <string>

namespace solidity::frontend::ethdebug
{

/// The two resource tables of ethdebug/format/info/resources.
struct Resources
{
	/// Type documents keyed by the compiler's type identifier. Composed types
	/// reference their component types by that identifier.
	std::map<std::string, langutil::ethdebug::schema::Type> types;
	/// Pointer templates keyed by layout and canonical type identifier.
	/// Reference types use their declared location; value types have storage,
	/// transient, memory and, when ABI-encodable, calldata templates.
	std::map<std::string, langutil::ethdebug::schema::Pointer::Template> pointers;

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

/// The scope record of @a _contract's state variables in storage and
/// transient storage: each materialized at its slot, a value type as a
/// region, a mapping as the region of its base slot and any other type
/// through the template of the type in resources(), with its declaration
/// and type reference. Followed by its immutable variables that have a copy
/// in the code, each materialized as the region of the code holding the value.
/// @param _immutableOffsets the byte offset in the code of one copy of the
/// value of each immutable variable, by the AST ID of its declaration. Empty
/// for the creation code, which holds none.
langutil::SemanticDebugScope stateVariableScope(
	ContractDefinition const& _contract,
	std::map<std::string, unsigned> const& _sourceIndices,
	std::map<int64_t, size_t> const& _immutableOffsets = {}
);

/// Consumes the scope to build the program-level context: every materialized
/// variable of @a _scope whose pointer is closed, i.e. reads no name that is
/// not bound within it, with its declaration, type reference and pointer.
/// The templates the pointer references are in @a _resources, with their
/// parameters bound by the pointer.
/// @returns nothing when no variable qualifies.
std::optional<langutil::ethdebug::schema::program::Context> programContext(
	langutil::SemanticDebugScope _scope,
	Resources const& _resources
);

/// The semantic debug info side table of @a _contract, as specified in
/// docs/compiler-guide/ethdebug_internal_debug_info.rst, together with its
/// resources(). It holds the scope record of the contract, with the state
/// variables in storage and transient storage as stateVariableScope()
/// describes them. A contract without such variables has no scope record.
langutil::SemanticDebugDataTable semanticDebugDataTable(
	ContractDefinition const& _contract,
	std::map<std::string, unsigned> const& _sourceIndices
);

}
