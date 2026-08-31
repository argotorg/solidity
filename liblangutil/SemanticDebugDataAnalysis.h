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
 * Analyses of ethdebug pointers shared by the Yul side table transfer and the
 * public emission.
 */

#pragma once

#include <liblangutil/SemanticDebugData.h>
#include <liblangutil/SemanticDebugDataTable.h>

#include <set>
#include <string>

namespace solidity::langutil
{

/// The names that @a _pointer reads and nothing inside it binds: generated Yul
/// locals (`$$yulLocal`) and variables not bound by a `define`, a list index or
/// a template parameter. Template references are followed through the local
/// templates blocks enclosing them and through the pointer templates of
/// @a _table; a reference to an unknown template contributes nothing.
std::set<std::string> semanticDebugPointerFreeNames(
	SemanticDebugPointer const& _pointer,
	SemanticDebugDataTable const& _table
);

/// Whether @a _pointer, including the templates it defines locally, still
/// contains a compiler-internal expression such as `$$yulLocal`. Templates in
/// the sidecar's table are not followed: they are rejected on deserialization
/// when they contain one.
bool semanticDebugPointerHasInternalExpression(SemanticDebugPointer const& _pointer);

} // namespace solidity::langutil
