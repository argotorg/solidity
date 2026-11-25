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
/// The JSON sidecar that carries the semantic debug info side table across a
/// textual Yul boundary, as specified in
/// docs/compiler-guide/ethdebug_internal_debug_info.rst.

#pragma once

#include <liblangutil/SemanticDebugDataTable.h>

#include <libsolutil/JSON.h>

#include <string_view>

namespace solidity::langutil
{

constexpr std::string_view SemanticDebugDataFormat = "solidity-ethdebug-semantic-data";
constexpr unsigned SemanticDebugDataFormatVersion = 1;

/// Writes @a _table as the sidecar: the format and version, the contract
/// name, the resource tables as ethdebug.resources has them, and the
/// scope records under the decimal AST ID and instance of their scope ID.
/// Internal expressions may appear in scope pointers, but not in resource templates.
/// Asserts that the table contains only records the producer can generate.
Json semanticDebugDataToJSON(SemanticDebugDataTable const& _table);

/// Copies a scope's uniquely owned pointer trees before rewriting its records.
SemanticDebugScope cloneSemanticDebugScope(SemanticDebugScope const& _scope);

/// Reads a sidecar written by semanticDebugDataToJSON, checking it against
/// the format: throws ethdebug::JsonValidationError, whose message names the
/// offending location, for an unknown format or version, a malformed
/// member, a scope key that is not a decimal integer in range, a variable
/// whose phase and pointer disagree, a template reference that resolves
/// neither locally nor in the pointer table, or a compiler-internal
/// expression in the pointer table.
SemanticDebugDataTable semanticDebugDataFromJSON(Json const& _json);

}
