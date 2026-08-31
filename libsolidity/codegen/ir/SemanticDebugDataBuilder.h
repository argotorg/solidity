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
 * Builds the semantic debug info of a contract from analysis results.
 */

#pragma once

#include <liblangutil/SemanticDebugDataTable.h>

#include <map>
#include <string>

namespace solidity::frontend
{

class ContractDefinition;

/// Builds the semantic debug info table of @a _contract from analysis results:
/// type documents, storage pointer templates and the scope records of the
/// contract's state variables, functions and modifiers. @a _sourceIndices maps
/// source unit names to the numeric source IDs of the ethdebug.compilation
/// record, which declaration ranges are published with.
langutil::SemanticDebugDataTable buildSemanticDebugDataTable(
	ContractDefinition const& _contract,
	std::map<std::string, unsigned> const& _sourceIndices
);

} // namespace solidity::frontend
