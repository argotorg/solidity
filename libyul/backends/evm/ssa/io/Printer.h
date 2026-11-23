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
 * Textual pretty-printer for libyul SSA CFGs.
 */

#pragma once

#include <libyul/backends/evm/ssa/SSACFGTypes.h>

#include <string>
#include <vector>

namespace solidity::yul::ssa
{

struct ControlFlowGraphs;

}

namespace solidity::yul::ssa::io
{

/// Lines that `print` adds to its output, each as `    ; <line>`. They are not part of the grammar.
class Annotator
{
public:
	using Lines = std::vector<std::string>;

	virtual ~Annotator() = default;
	/// Lines in front of the first block of a graph
	virtual Lines atGraph(FunctionGraphID) const { return {}; }
	/// Lines below the header of a block
	virtual Lines atBlockEntry(FunctionGraphID, BlockId) const { return {}; }
	/// Lines in front of an instruction
	virtual Lines atInstruction(FunctionGraphID, InstId) const { return {}; }
	/// Lines in front of the exit of a block
	virtual Lines atExit(FunctionGraphID, BlockId) const { return {}; }
};

/// Produces a textual rendering of `_cfgs`
void print(std::ostream& _out, ControlFlowGraphs const& _cfgs, Annotator const& _annotator = {});

}
