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

#include <libyul/backends/evm/ssa/transform/UseCounts.h>

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <libsolutil/Visitor.h>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::transform;

UseCounts::UseCounts(SSACFG const& _cfg): m_counts(_cfg.numInsts(), 0)
{
	auto const countUse = [&](InstId const _use) { ++m_counts[_use.value]; };
	for (BlockId const blockId: _cfg.liveBlocks())
	{
		auto const& block = _cfg.block(blockId);
		for (InstId const instId: block.instructions)
			for (InstId const input: _cfg.inst(instId).inputs)
				countUse(input);
		std::visit(solidity::util::GenericVisitor{
			[&](SSACFG::BasicBlock::ConditionalJump const& _conditionalJump) {
				countUse(_conditionalJump.condition);
			},
			[&](SSACFG::BasicBlock::FunctionReturn const& _functionReturn) {
				for (InstId const returnValue: _functionReturn.returnValues)
					countUse(returnValue);
			},
			[](SSACFG::BasicBlock::Jump const&) {},
			[](SSACFG::BasicBlock::MainExit const&) {},
			[](SSACFG::BasicBlock::Terminated const&) {}
		}, block.exit);
	}
}
