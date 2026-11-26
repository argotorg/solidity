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
#include <libyul/backends/evm/ssa/transform/NonContinuingCallTerminator.h>

#include <libyul/backends/evm/ssa/CallGraph.h>
#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>

#include <range/v3/algorithm/find_if.hpp>
#include <range/v3/view/subrange.hpp>

using namespace solidity::yul::ssa;

void transform::terminateNonContinuingCalls(ControlFlowGraphs& _cfgs)
{
	CallGraph const callGraph(_cfgs);
	for (auto& cfg: _cfgs.functionGraphs)
		for (BlockId const blockId: cfg->liveBlocks())
		{
			auto& block = cfg->block(blockId);
			auto const call = ranges::find_if(block.instructions, [&](InstId const _id) {
				return !callGraph.canContinue(*cfg, _id);
			});
			if (call == block.instructions.end())
				continue;

			// Nothing behind the call is executed.
			auto const behindCall = call + 1 + cfg->numTrailingProjections(*call);
			for (InstId const id: ranges::make_subrange(behindCall, block.instructions.end()))
				cfg->tombstone(id);
			block.instructions.erase(behindCall, block.instructions.end());
			block.forEachExit([&](BlockId const _successor) { std::erase(cfg->block(_successor).entries, blockId); });
			block.exit = SSACFG::BasicBlock::Terminated{};
		}
}
