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

#include <libyul/backends/evm/ssa/transform/JumpThreader.h>

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <libyul/Exceptions.h>

#include <range/v3/algorithm/any_of.hpp>
#include <range/v3/range/conversion.hpp>

#include <variant>
#include <vector>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;

namespace
{

bool mergeSuccessorIntoPredecessor(SSACFG& _cfg, BlockId const _predecessor, BlockId const _successor)
{
	auto& predecessorBlock = _cfg.block(_predecessor);
	auto& successorBlock = _cfg.block(_successor);

	yulAssert(successorBlock.entries.size() == 1);
	// Cannot thread through a block that carries phis
	yulAssert(!ranges::any_of(successorBlock.instructions, [&](InstId const _id) { return _cfg.isPhi(_id); }));

	// Re-home the target's instructions into the source (their defining block moves along).
	for (InstId const id: successorBlock.instructions)
		_cfg.inst(id).block = _predecessor;
	predecessorBlock.instructions.insert(
		predecessorBlock.instructions.end(),
		successorBlock.instructions.begin(),
		successorBlock.instructions.end()
	);
	successorBlock.instructions.clear();

	// The source takes over the target's exit and the associated exit debug data.
	predecessorBlock.exit = successorBlock.exit;
	if (_cfg.debugInfo)
		_cfg.debugInfo->setExitDebugData(_predecessor, _cfg.debugInfo->exitDebugData(_successor));

	// Every successor of the adopted exit now has the source as its predecessor instead of the target.
	predecessorBlock.forEachExit([&](BlockId const _succ) {
		for (BlockId& entry: _cfg.block(_succ).entries)
			if (entry == _successor)
				entry = _predecessor;
	});

	// `_target` is now unreachable
	successorBlock.exit = SSACFG::BasicBlock::Terminated{};
	return true;
}

}

void transform::threadJumps(SSACFG& _cfg)
{
	// Absorbing a successor changes only the predecessor's exit, i.e., we can operate locally: once a block
	// takes over its successor's exit, that exit may again be threadable into the very same block.
	for (BlockId const blockId: _cfg.liveBlocks())
		while (true)
		{
			auto const* jump = std::get_if<SSACFG::BasicBlock::Jump>(&_cfg.block(blockId).exit);
			if (!jump)
				break;
			BlockId const target = jump->target;
			if (target == blockId)  // can't thread self-loops
				break;
			if (target == _cfg.entry)  // the entry is special as it already has one control predecessor (the entry itself)
				break;
			if (_cfg.block(target).entries.size() != 1)
				break;
			yulAssert(_cfg.block(target).entries.front() == blockId);
			if (!mergeSuccessorIntoPredecessor(_cfg, blockId, target))
				break;
		}
}
