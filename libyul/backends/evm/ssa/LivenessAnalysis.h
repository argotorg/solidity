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

#include <libyul/backends/evm/ssa/traversal/ForwardTopologicalSort.h>
#include <libyul/backends/evm/ssa/SSACFG.h>
#include <libyul/backends/evm/ssa/SSACFGLoopNestingForest.h>
#include <libyul/backends/evm/ssa/util/UseCountSet.h>

#include <boost/container/flat_map.hpp>

#include <vector>

namespace solidity::yul::ssa
{

/// Performs liveness analysis on a reducible SSA CFG following Algorithm 9.1 in [1].
///
/// Liveness is computed over `Variable`s: non-literal SSA values and phi shadows. A phi shadow `^p` is written
/// by every upsilon targeting `p`, therefore it is not in SSA but in SSU (static single use) form. The loop propagation
/// of [1] relies on single definitions but only overapproximates (an upsilon targeting a phi in a loop body overwrites
/// an upsilon targeting the same phi that is live in the loop head but we still consider it live throughout).
///
/// [1] Rastello, Fabrice, and Florent Bouchez Tichadou, eds. SSA-based Compiler Design. Springer, 2022.
class LivenessAnalysis
{
public:
	/// Per-program-point liveness, each variable's use count is the max number of times the variable will be read
	/// along all paths downstream of that point
	using LivenessData = util::UseCountSet<Variable>;

	explicit LivenessAnalysis(SSACFG const& _cfg);

	LivenessData const& liveIn(SSACFG::BlockId const _blockId) const { return m_liveIns[_blockId.value]; }
	LivenessData const& liveOut(SSACFG::BlockId const _blockId) const { return m_liveOuts[_blockId.value]; }
	LivenessData used(SSACFG::BlockId _blockId) const;
	/// Liveness right after the operation, phi, upsilon or identity `_id`
	LivenessData const& operationLiveOut(InstId const _id) const { return m_operationLiveOutByInst.at(_id.value); }
	traversal::ForwardTopologicalSort const& topologicalSort() const { return m_topologicalSort; }
	SSACFG const& cfg() const { return m_cfg; }

private:
	void runDagDfs();
	void runLoopTreeDfs(SSACFG::BlockId::ValueType _loopHeader);
	void fillOperationsLiveOut();
	LivenessData blockExitValues(SSACFG::BlockId const& _blockId) const;
	/// Transfers `_live` backwards over `_instId`. Returns whether the Inst is a program point at all,
	/// leaving `_live` untouched otherwise.
	bool transferBackwards(InstId _instId, SSACFG::Inst const& _inst, LivenessData& _live) const;

	auto excludingLiteralsFilter() const
	{
		return [this](InstId _v) { return !m_cfg.isLiteral(_v); };
	}

	SSACFG const& m_cfg;
	traversal::ForwardTopologicalSort m_topologicalSort;
	SSACFGLoopNestingForest m_loopNestingForest;
	std::vector<LivenessData> m_liveIns;
	std::vector<LivenessData> m_liveOuts;
	boost::container::flat_map<InstId::ValueType, LivenessData> m_operationLiveOutByInst;
};

}
