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

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>

#include <libyul/backends/evm/ssa/analysis/ReducibilityCheck.h>

#include <libsolutil/Visitor.h>

#include <boost/container/flat_map.hpp>

#include <range/v3/view/enumerate.hpp>
#include <range/v3/view/filter.hpp>
#include <range/v3/view/reverse.hpp>

#include <utility>
#include <vector>

using namespace solidity::yul::ssa;

LivenessAnalysis::LivenessData LivenessAnalysis::blockExitValues(SSACFG::BlockId const& _blockId) const
{
	LivenessData result;
	solidity::util::GenericVisitor exitVisitor{
		[](SSACFG::BasicBlock::MainExit const&) {},
		[&](SSACFG::BasicBlock::FunctionReturn const& _functionReturn)
		{
			result.insertAll(_functionReturn.returnValues | ranges::views::filter(excludingLiteralsFilter()));
		},
		[](SSACFG::BasicBlock::Jump const&) {},
		[&](SSACFG::BasicBlock::ConditionalJump const& _conditionalJump)
		{
			if (excludingLiteralsFilter()(_conditionalJump.condition))
				result.insert(_conditionalJump.condition);
		},
		[](SSACFG::BasicBlock::Terminated const&) {}};
	std::visit(exitVisitor, m_cfg.block(_blockId).exit);
	return result;
}

template<typename Callable>
void LivenessAnalysis::liveOutToLiveIn(
	SSACFG::BlockId const _blockId,
	LivenessData& _live,
	Callable&& _atOperation
) const
{
	// add value ids to the live set that are used in exit blocks
	_live += blockExitValues(_blockId);

	for (InstId const instId: m_cfg.block(_blockId).instructions | ranges::views::reverse)
	{
		auto const& inst = m_cfg.inst(instId);
		if (inst.isPhi())
			_live.erase(instId);
		if (!inst.isOperation())
			continue;
		_atOperation(instId, std::as_const(_live));
		// remove variables defined at p from live
		_live.eraseAll(m_cfg.projectionsOf(instId));
		_live.erase(instId);
		_live.insertAll(inst.inputs | ranges::views::filter(excludingLiteralsFilter()));
	}
}

LivenessAnalysis::LivenessAnalysis(SSACFG const& _cfg):
	m_cfg(_cfg),
	m_dfsTree(_cfg),
	m_loopNestingForest(m_dfsTree),
	m_shadows(m_dfsTree),
	m_liveIns(_cfg.numBlocks()),
	m_liveOuts(_cfg.numBlocks())
{
	yulAssert(analysis::isReducibleCFG(m_dfsTree), "Liveness analysis only implemented for reducible CFGs");
	runDagDfs();
	for (auto const loopRootNode: m_loopNestingForest.loopRootNodes())
		runLoopTreeDfs(loopRootNode);

	fillOperationsLiveOut();
}

LivenessAnalysis::LivenessData LivenessAnalysis::used(SSACFG::BlockId const _blockId) const
{
	auto used = liveIn(_blockId);
	for (auto const& [valueId, count]: liveOut(_blockId))
		used.remove(valueId, count);
	return used;
}

void LivenessAnalysis::runDagDfs()
{
	// SSA Book, Algorithm 9.2
	for (SSACFG::BlockId const blockId: m_dfsTree.postOrder())
	{
		// post-order traversal
		auto const& block = m_cfg.block(blockId);

		// live <- PhiUses(B), the inputs of the writes at the block's exit that reach a phi
		LivenessData live{};
		for (auto const& [phi, v]: m_shadows.liveWrites(blockId))
		{
			yulAssert(!m_cfg.isUnreachable(v));
			if (!m_cfg.isLiteral(v))
				live.insert(v);
		}

		// for each S \in succs(B) s.t. (B, S) not a back edge: live <- live \cup LiveIn(S)
		// (a phi is defined at its position, so there are no PhiDefs(S) to take out)
		block.forEachExit(
			[&](SSACFG::BlockId const& _successor) {
				if (!m_dfsTree.backEdge(blockId, _successor))
					live.maxUnion(m_liveIns[_successor.value]);
			});

		if (std::holds_alternative<SSACFG::BasicBlock::FunctionReturn>(block.exit))
			live.insertAll(std::get<SSACFG::BasicBlock::FunctionReturn>(block.exit).returnValues | ranges::views::filter(excludingLiteralsFilter()));

		// clean out unreachables
		live.eraseIf([&](auto const& _entry) { return m_cfg.isUnreachable(_entry.first); });

		// LiveOut(B) <- live
		m_liveOuts[blockId.value] = live;

		// for each program point p in B, backwards, do:
		liveOutToLiveIn(blockId, live, [](InstId, LivenessData const&) {});

		// livein(b) <- live
		m_liveIns[blockId.value] = live;
	}
}

void LivenessAnalysis::runLoopTreeDfs(SSACFG::BlockId const _loopHeader)
{
	// SSA Book, Algorithm 9.3
	if (m_loopNestingForest.loopNodes().contains(_loopHeader))
	{
		// LiveLoop <- LiveIn(B_N) (the header's phis are defined at their position, not live on entry)
		auto liveLoop = m_liveIns[_loopHeader.value];
		// must be live out of header if live in of children
		m_liveOuts[_loopHeader.value].maxUnion(liveLoop);
		// for each blockId \in children(loopHeader)
		for (SSACFG::BlockId const blockId: m_cfg.liveBlocks())
			if (m_loopNestingForest.loopParent(blockId) == _loopHeader)
			{
				// propagate loop liveness information down to the loop header's children
				m_liveIns[blockId.value].maxUnion(liveLoop);
				m_liveOuts[blockId.value].maxUnion(liveLoop);

				runLoopTreeDfs(blockId);
			}
	}
}

void LivenessAnalysis::fillOperationsLiveOut()
{
	for (SSACFG::BlockId const blockId: m_cfg.liveBlocks())
	{
		auto live = m_liveOuts[blockId.value];
		liveOutToLiveIn(blockId, live, [&](InstId const _operation, LivenessData const& _liveOut) {
			m_operationLiveOutByInst.emplace(_operation.value, _liveOut);
		});
	}
}
