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
/// The compiler structures of the semantic debug info specified in
/// docs/compiler-guide/ethdebug_internal_debug_info.rst: the scope records that
/// describe the variables of a source-language scope in ethdebug terms.

#pragma once

#include <liblangutil/EthdebugSchema.h>

#include <compare>
#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <vector>

namespace solidity::langutil
{

/// Identifies a scope record: the AST ID of the source-language scope it was
/// generated from, together with an instance discriminator. Code generation
/// produces instance 0 only; passes that clone code give each copy its own
/// instance. In Yul text the instance travels in the `@ast-id-instance`
/// annotation next to `@ast-id`.
struct ScopeID
{
	int64_t astID = 0;
	int64_t instance = 0;

	auto operator<=>(ScopeID const&) const = default;
};

/// Whether a variable's value can be recovered at a program point. The region
/// a materialized value lives in is not duplicated here: the variable's
/// pointer records it.
enum class SemanticDebugVariablePhase
{
	/// The value has a concrete representation described by the variable's pointer.
	Materialized,
	/// The value has no region because the program recomputes it where it is
	/// used. No recovery recipe is carried; the phase only records that
	/// recomputation would be possible in principle, unlike OptimizedOut.
	Computed,
	/// No recoverable representation is available at this program point.
	OptimizedOut,
};

/// A variable of a scope. @a pointer is present exactly when the phase is
/// Materialized; the sidecar reader and writer enforce this.
struct SemanticDebugVariable
{
	/// The source-level name. Synthetic bindings have none.
	std::optional<std::string> identifier;
	/// The AST ID of the source-language declaration. Synthetic bindings have none.
	std::optional<int64_t> declarationASTID;
	/// The declaration's range, with the source ID of the ethdebug
	/// compilation record.
	std::optional<ethdebug::schema::materials::SourceRange> declarationSourceRange;
	/// The ID of the variable's type document in the type resources.
	std::optional<std::string> typeID;
	SemanticDebugVariablePhase phase = SemanticDebugVariablePhase::OptimizedOut;
	/// Where the value lives, in ethdebug pointer terms. Stack values are
	/// expressed over generated Yul locals until Yul is compiled to EVM.
	std::optional<ethdebug::schema::Pointer> pointer;
};

/// A change of a variable's phase or pointer at the point where the scope
/// record is attached. Produced by optimizer passes, not by code generation.
/// At least one of @a phase and @a pointer is present.
struct SemanticDebugVariableUpdate
{
	int64_t variableASTID = 0;
	std::optional<SemanticDebugVariablePhase> phase;
	std::optional<ethdebug::schema::Pointer> pointer;
};

/// The record of one scope. Immutable once created and shared between the
/// Yul nodes that carry it and the side table.
struct SemanticDebugScope
{
	using ConstPtr = std::shared_ptr<SemanticDebugScope const>;

	std::vector<SemanticDebugVariable> variableDefinitions;
	std::vector<SemanticDebugVariableUpdate> variableUpdates;
};

}
