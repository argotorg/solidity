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

#include <libyul/backends/evm/ssa/transform/UnreachableBlockCleaner.h>

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <vector>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::transform;

void transform::cleanUnreachableBlocks(SSACFG& _cfg)
{
	auto reachable = _cfg.reachableBlocks();

	auto& store = _cfg.instructionStore();
	for (SSACFG::BlockId const blockId: _cfg.liveBlocks())
	{
		if (reachable.contains(blockId))
			std::erase_if(_cfg.block(blockId).entries, [&](auto const& entry) { return !reachable.contains(entry); });
		else
		{
			for (InstId const id: _cfg.block(blockId).instructions)
				store.tombstone(id);
			_cfg.resetBlock(blockId);
		}
	}
}
