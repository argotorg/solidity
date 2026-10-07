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

#include <libyul/backends/evm/ssa/analysis/DepthFirstSpanningTree.h>
#include <libyul/backends/evm/ssa/SSACFG.h>
#include <libyul/backends/evm/ssa/analysis/LoopNestingForest.h>
#include <libyul/backends/evm/ssa/util/UseCountSet.h>

#include <boost/container/flat_map.hpp>

#include <functional>
#include <memory>
#include <vector>

namespace solidity::yul::ssa
{
struct ControlFlowGraphs;
}

namespace solidity::yul::ssa::analysis
{

/// Performs liveness analysis on a reducible SSA CFG following Algorithm 9.1 in [1].
///
/// [1] Rastello, Fabrice, and Florent Bouchez Tichadou, eds. SSA-based Compiler Design. Springer, 2022.
class Liveness
{
public:
	/// Per-program-point liveness, each value's use count is the max number of times the value will be read along
	/// all paths downstream of that point
	using Data = util::UseCountSet<InstId>;

	explicit Liveness(SSACFG const& _cfg);

	Data const& liveIn(SSACFG::BlockId const _blockId) const { return m_liveIns[_blockId.value]; }
	Data const& liveOut(SSACFG::BlockId const _blockId) const { return m_liveOuts[_blockId.value]; }
	Data used(SSACFG::BlockId _blockId) const;
	Data const& operationLiveOut(InstId const _id) const { return m_operationLiveOutByInst.at(_id.value); }
	DepthFirstSpanningTree const& dfsTree() const { return m_dfsTree; }
	SSACFG const& cfg() const { return m_cfg; }

private:
	void runDagDfs();
	void runLoopTreeDfs(SSACFG::BlockId _loopHeader);
	void fillOperationsLiveOut();
	Data blockExitValues(SSACFG::BlockId const& _blockId) const;

	auto excludingLiteralsFilter() const
	{
		return [this](InstId _v) { return !m_cfg.isLiteral(_v); };
	}

	SSACFG const& m_cfg;
	DepthFirstSpanningTree m_dfsTree;
	LoopNestingForest m_loopNestingForest;
	std::vector<Data> m_liveIns;
	std::vector<Data> m_liveOuts;
	boost::container::flat_map<InstId::ValueType, Data> m_operationLiveOutByInst;
};

struct ControlFlowGraphsLiveness
{
	explicit ControlFlowGraphsLiveness(ControlFlowGraphs const& _controlFlow);

	std::reference_wrapper<ControlFlowGraphs const> controlFlowGraphs;
	std::vector<std::unique_ptr<Liveness>> cfgLiveness;
};

}
