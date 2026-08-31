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
 * JSON serialization of the semantic debug info side table: the ethdebug
 * sidecar that crosses a textual Yul boundary.
 *
 * The envelope and the variable records are compiler-specific and versioned.
 * The type and pointer documents inside them follow the public ethdebug
 * schemas, with the single internal `$$yulLocal` expression for a generated
 * Yul local whose stack depth is not known yet.
 */

#pragma once

#include <liblangutil/Exceptions.h>
#include <liblangutil/SemanticDebugData.h>
#include <liblangutil/SemanticDebugDataTable.h>

#include <libsolutil/JSON.h>

#include <string_view>

namespace solidity::langutil
{

inline constexpr std::string_view SemanticDebugDataFormat = "solidity-ethdebug-semantic-data";
inline constexpr unsigned SemanticDebugDataFormatVersion = 1;

/// Raised for a sidecar that is malformed and for a pointer that cannot be
/// represented in the ethdebug pointer schema.
struct SemanticDebugDataSerializationError: virtual util::Exception {};

/// Serializes the side table: the resource tables and every scope record,
/// attached to a Yul node or not.
Json semanticDebugDataToJson(SemanticDebugDataTable const& _table);

/// Deserializes a sidecar, rejecting an unknown format, an unsupported
/// version, malformed fields and template references that resolve neither to
/// a local templates block nor to the sidecar's pointer table.
SemanticDebugDataTable semanticDebugDataFromJson(Json const& _json);

/// Serializes @a _pointer as an ethdebug pointer document; a root pointer that
/// expects parameters takes the schema's template form. Public emission uses
/// the same writer, after checking that no internal expression remains.
Json semanticDebugPointerToJson(SemanticDebugPointer const& _pointer);

/// Serializes @a _template as an ethdebug pointer template document, i.e. in
/// the `expect`/`for` form also when it expects no parameters.
Json semanticDebugPointerTemplateToJson(SemanticDebugPointer const& _template);

} // namespace solidity::langutil
