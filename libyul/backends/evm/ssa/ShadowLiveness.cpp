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

#include <libyul/backends/evm/ssa/ShadowLiveness.h>

#include <libyul/backends/evm/ssa/analysis/DepthFirstSpanningTree.h>
#include <libyul/Exceptions.h>

#include <fmt/format.h>

using namespace solidity::yul::ssa;

ShadowLiveness::ShadowLiveness(analysis::DepthFirstSpanningTree const& _dfsTree):
	m_liveIns(_dfsTree.cfg().numBlocks()),
	m_liveOuts(_dfsTree.cfg().numBlocks())
{
	SSACFG const& cfg = _dfsTree.cfg();
	// Defs(B): the phis whose shadows each block writes
	std::vector<ShadowSet> written(cfg.numBlocks());
	for (SSACFG::BlockId const blockId: _dfsTree.preOrder())
		cfg.forEachUpsilon(cfg.block(blockId), [&](InstId const _upsilon, SSACFG::Inst const&) {
			written[blockId.value].insert(cfg.upsilonPhi(_upsilon));
		});

	// SSA Book, Algorithm 9.9: for each variable v and each block B that uses v, walk up from B.
	// Here v is the shadow of a phi. Its only use is the phi, which reads it in its own block,
	// so there is one walk per phi, and the PhiUses step has no counterpart.
	std::vector<SSACFG::BlockId> toVisit;
	for (SSACFG::BlockId const blockId: _dfsTree.preOrder())
	{
		// the phis whose shadows the block writes ahead of the current Inst
		ShadowSet writtenAhead;
		for (InstId const id: cfg.block(blockId).instructions)
		{
			if (cfg.isUpsilon(id))
				writtenAhead.insert(cfg.upsilonPhi(id));
			if (!cfg.isPhi(id))
				continue;
			// SSA Book, Algorithm 9.10, Up_and_Mark_Stack(B, v), with sets instead of stacks and a worklist instead
			// of the recursion. PhiDefs has no counterpart, as phis don't define shadows.
			//
			// Its first step, `if v \in Defs(B): return`, is not done for the block of the phi.
			// Only an upsilon ahead of the phi would kill the shadow, and that is asserted not to occur.
			yulAssert(
				!writtenAhead.contains(id),
				fmt::format("phi {} is written ahead of itself in its block, which is not supported yet", id)
			);
			// the phi reads its shadow: it is live on entry, and backwards from there up to the last upsilon for
			// the phi on every path
			yulAssert(blockId != cfg.entry, fmt::format("phi {} reads its shadow before any upsilon writes it", id));
			// push(LiveIn(B), v)
			m_liveIns[blockId.value].insert(id);
			// foreach P \in CFG_directpreds(B)
			toVisit.assign(cfg.block(blockId).entries.begin(), cfg.block(blockId).entries.end());
			while (!toVisit.empty())
			{
				SSACFG::BlockId const predecessor = toVisit.back();
				toVisit.pop_back();
				// if top(LiveOut(P)) != v: push(LiveOut(P), v). If v was live-out of P already, P has been walked.
				if (!_dfsTree.reachable(predecessor) || !m_liveOuts[predecessor.value].insert(id).second)
					continue;
				// Up_and_Mark_Stack(P, v), the recursive call, i.e., with P as its B:
				// if v \in Defs(B): return, if top(LiveIn(B)) = v: return, push(LiveIn(B), v)
				if (written[predecessor.value].contains(id) || !m_liveIns[predecessor.value].insert(id).second)
					continue;
				// The definition of an SSA value dominates its uses, so the walk of the book always ends in Defs.
				// For shadows getting past the entry would mean a path reaches the phi without a write.
				yulAssert(predecessor != cfg.entry, fmt::format("phi {} reads its shadow before any upsilon writes it", id));
				// foreach P \in CFG_directpreds(B) of the same call, visited through the worklist
				auto const& entries = cfg.block(predecessor).entries;
				toVisit.insert(toVisit.end(), entries.begin(), entries.end());
			}
		}
	}
}
