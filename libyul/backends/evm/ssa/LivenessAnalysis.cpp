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

LivenessAnalysis::LivenessAnalysis(SSACFG const& _cfg):
	m_cfg(_cfg),
	m_topologicalSort(_cfg),
	m_loopNestingForest(m_topologicalSort),
	m_liveIns(_cfg.numBlocks()),
	m_liveOuts(_cfg.numBlocks())
{
	runDagDfs();
	for (auto const loopRootNode: m_loopNestingForest.loopRootNodes())
		runLoopTreeDfs(loopRootNode);

	// Whatever is live-in at the entry is a read without a write which is only allowed for function arguments
	for (auto const& variable: m_liveIns[m_cfg.entry.value] | std::views::keys)
		yulAssert(m_cfg.isFunctionArg(variable.inst), fmt::format("{} is read on a path from the entry that never defines it", variable));

	fillOperationsLiveOut();
}

LivenessAnalysis::LivenessData LivenessAnalysis::used(SSACFG::BlockId const _blockId) const
{
	auto used = liveIn(_blockId);
	for (auto const& [valueId, count]: liveOut(_blockId))
		used.remove(valueId, count);
	return used;
}

bool LivenessAnalysis::transferBackwards(InstId const _instId, SSACFG::Inst const& _inst, LivenessData& _live) const
{
	switch (_inst.opcode)
	{
	case InstOpcode::Call:
	case InstOpcode::BuiltinCall:
	case InstOpcode::MemoryGuard:
		// remove variables defined at p from live
		_live.eraseAll(m_cfg.projectionsOf(_instId));
		_live.erase(_instId);
		_live.insertAll(_inst.inputs | ranges::views::filter(excludingLiteralsFilter()));
		return true;
	case InstOpcode::Phi:
	{
		// the phi defines its value by reading its shadow; a dead phi does not keep its shadow alive
		bool const phiIsLive = _live.contains(_instId);
		_live.erase(_instId);
		if (phiIsLive)
			_live.insert(Variable::shadow(_instId));
		return true;
	}
	case InstOpcode::Upsilon:
	{
		// the upsilon overwrites the shadow of its phi with its input
		_live.erase(Variable::shadow(m_cfg.upsilonPhi(_instId)));
		InstId const v = _inst.inputs.at(0);
		yulAssert(!m_cfg.isUnreachable(v));
		if (!m_cfg.isLiteral(v))
			_live.insert(v);
		return true;
	}
	case InstOpcode::Identity:
		// defines its value by reading its input
		_live.erase(_instId);
		_live.insertAll(_inst.inputs | ranges::views::filter(excludingLiteralsFilter()));
		return true;
	case InstOpcode::Const:
	case InstOpcode::FunctionArg:
	case InstOpcode::Projection:
	case InstOpcode::Nop:
		// no program point: definitions that are not executed, or nothing at all
		return false;
	case InstOpcode::Unreachable:
	case InstOpcode::Tombstone:
		yulAssert(false, fmt::format("unexpected Inst {} in a block", _instId));
	}
	solidity::util::unreachable();
}

void LivenessAnalysis::runDagDfs()
{
	// SSA Book, Algorithm 9.2
	for (auto const blockIdValue: m_topologicalSort.postOrder())
	{
		// post-order traversal
		SSACFG::BlockId blockId{blockIdValue};
		auto const& block = m_cfg.block(blockId);

		// Phis and upsilons are positioned reads and writes of the phi shadows, handled by the backwards walk
		// below in place of PhiUses(B) / PhiDefs(B) at the block boundaries.
		LivenessData live{};
		block.forEachExit(
			[&](SSACFG::BlockId const& _successor) {
				if (!m_topologicalSort.backEdge(blockId, _successor))
					// for each S \in succs(B) s.t. (B, S) not a back edge: live <- live \cup LiveIn(S)
					live.maxUnion(m_liveIns[_successor.value]);
				else
					// the shadows of the loop header's phis are live across the back edge
					m_cfg.forEachPhi(m_cfg.block(_successor), [&](InstId const phiId, SSACFG::Inst const&) {
						live.insert(Variable::shadow(phiId));
					});
			});

		if (std::holds_alternative<SSACFG::BasicBlock::FunctionReturn>(block.exit))
			live.insertAll(std::get<SSACFG::BasicBlock::FunctionReturn>(block.exit).returnValues | ranges::views::filter(excludingLiteralsFilter()));

		// clean out unreachables
		live.eraseIf([&](auto const& _entry) { return _entry.first.isValue() && m_cfg.isUnreachable(_entry.first.inst); });

		// LiveOut(B) <- live
		m_liveOuts[blockId.value] = live;

		// for each program point p in B, backwards, do:
		{
			// add value ids to the live set that are used in exit blocks
			live += blockExitValues(blockId);

			for (InstId const instId: block.instructions | ranges::views::reverse)
				transferBackwards(instId, m_cfg.inst(instId), live);
		}

		// livein(b) <- live
		m_liveIns[blockId.value] = live;
	}
}

void LivenessAnalysis::runLoopTreeDfs(SSACFG::BlockId::ValueType const _loopHeader)
{
	// SSA Book, Algorithm 9.3
	if (m_loopNestingForest.loopNodes().contains(_loopHeader))
	{
		// the loop header block id
		auto const& block = m_cfg.block(SSACFG::BlockId{_loopHeader});
		// LiveLoop <- LiveIn(B_N) - PhiDefs(B_N)
		// the header phis' shadows are live-in at the header but redefined inside the loop
		auto liveLoop = m_liveIns[_loopHeader];
		m_cfg.forEachPhi(block, [&](InstId const instId, SSACFG::Inst const&) {
			liveLoop.erase(Variable::shadow(instId));
		});
		// must be live out of header if live in of children
		m_liveOuts[_loopHeader].maxUnion(liveLoop);
		// for each blockId \in children(loopHeader)
		for (SSACFG::BlockId const blockId: m_cfg.liveBlocks())
			if (m_loopNestingForest.loopParents()[blockId.value] == _loopHeader)
			{
				// propagate loop liveness information down to the loop header's children
				m_liveIns[blockId.value].maxUnion(liveLoop);
				m_liveOuts[blockId.value].maxUnion(liveLoop);

				runLoopTreeDfs(blockId.value);
			}
	}
}

void LivenessAnalysis::fillOperationsLiveOut()
{
	for (SSACFG::BlockId const blockId: m_cfg.liveBlocks())
	{
		auto const& block = m_cfg.block(blockId);
		auto live = m_liveOuts[blockId.value];
		live += blockExitValues(blockId);
		for (InstId const instId: block.instructions | ranges::views::reverse)
		{
			LivenessData const liveOut = live;
			if (transferBackwards(instId, m_cfg.inst(instId), live))
				m_operationLiveOutByInst.emplace(instId.value, liveOut);
		}
	}
}
