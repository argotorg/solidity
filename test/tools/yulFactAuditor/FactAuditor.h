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

#pragma once

#include <libyul/ASTForward.h>

#include <libsolutil/CommonData.h>

#include <cstddef>
#include <optional>
#include <string>
#include <vector>

namespace solidity::yul
{
class Dialect;
}

namespace solidity::yul::test
{

/// Inserts a runtime check of every fact the DataFlowAnalyzer claims before each statement of @a _ast.
/// A failing check reverts with its fact's index as a single word of revert data, so the instrumented code itself
/// must never revert with exactly 32 bytes.
/// Requires disambiguated code with empty for-loop init blocks and no function definitions inside loops.
/// @returns the facts, as Yul conditions.
std::vector<std::string> instrumentWithFactChecks(Dialect const& _dialect, Block& _ast);

/// @returns the index, into the vector returned by instrumentWithFactChecks, of the fact whose check failed, if any,
/// given the data of the revert that ended the run.
std::optional<std::size_t> violatedFactIndex(bytes const& _revertData);

}
