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
 * Moves semantic debug info between the (AST ID, instance)-keyed side table
 * and the DebugData of Yul AST nodes.
 */

#pragma once

#include <liblangutil/SemanticDebugDataTable.h>

namespace solidity::yul
{

class Object;

/// Collects the scope records attached to the Yul AST nodes of @a _object and
/// its sub-objects into @a _table, keyed by (AST ID, instance). A record
/// already in the table for the same key is replaced; records with no
/// attached node are left untouched.
void collectSemanticDebugData(Object const& _object, langutil::SemanticDebugDataTable& _table);

/// Attaches the scope records of @a _table to every Yul AST node of
/// @a _object and its sub-objects whose (AST ID, instance) has a record.
/// Pointers are checked per object: a materialized variable whose pointer
/// reads a generated Yul local that does not exist in that object's code is
/// attached there as optimized-out without a pointer, even if the local exists
/// in a sibling object. @a _table receives the records as attached, so it
/// describes the same state as the AST; where an object attaches a record that
/// a sibling object also attaches, the sibling visited last wins.
void applySemanticDebugData(Object& _object, langutil::SemanticDebugDataTable& _table);

}
