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
 * Lowers the internal semantic debug info to the public ethdebug resource
 * tables and program context.
 */

#pragma once

#include <liblangutil/SemanticDebugDataTable.h>

#include <libevmasm/EthdebugSchema.h>

#include <libsolutil/JSON.h>

#include <optional>

namespace solidity::frontend::ethdebug
{

/// The public ethdebug resource tables of a side table: the type documents
/// verbatim and the pointer templates in the schema's template form, under
/// the producer-defined names the sidecar keys them by.
struct Resources
{
	Json types = Json::object();
	Json pointers = Json::object();

	/// Adds the tables of @a _other, replacing entries with the same key.
	void merge(Resources const& _other);
};

Resources resources(langutil::SemanticDebugDataTable const& _table);

/// The program-level ethdebug context: every materialized variable whose
/// pointer is closed, i.e. reads neither a generated Yul local nor an unbound
/// variable, with its declaration range, its type reference and, when its
/// pointer template expects no parameters, the pointer itself. A template that
/// expects parameters, such as mapping keys, stays in the resources for the
/// consumer to instantiate, and the variable is listed without a pointer.
/// @returns nothing when no variable qualifies.
std::optional<evmasm::ethdebug::schema::program::Context> programContext(
	langutil::SemanticDebugDataTable const& _table
);

}
