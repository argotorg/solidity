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

#include <libyul/backends/evm/ssa/CallGraph.h>

#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>

#include <libsolutil/TarjanSCC.h>

#include <libyul/Exceptions.h>

#include <range/v3/algorithm/any_of.hpp>
#include <range/v3/algorithm/binary_search.hpp>
#include <range/v3/algorithm/sort.hpp>
#include <range/v3/algorithm/unique.hpp>
#include <range/v3/view/enumerate.hpp>
#include <range/v3/view/zip.hpp>

using namespace solidity::yul::ssa;

namespace
{

/// Whether `_cfg` reaches a return without passing an instruction that cannot continue according to `_callGraph`
bool reachesReturn(SSACFG const& _cfg, CallGraph const& _callGraph)
{
	auto const cannotContinue = [&](InstId const _id) { return !_callGraph.canContinue(_cfg, _id); };
	std::vector<bool> visited(_cfg.numBlocks(), false);
	visited[_cfg.entry.value] = true;
	std::vector<BlockId> toVisit{_cfg.entry};
	while (!toVisit.empty())
	{
		SSACFG::BasicBlock const& block = _cfg.block(toVisit.back());
		toVisit.pop_back();
		if (ranges::any_of(block.instructions, cannotContinue))
			continue;
		if (block.isFunctionReturnBlock())
			return true;
		block.forEachExit([&](BlockId const _successor) {
			if (!visited[_successor.value])
			{
				visited[_successor.value] = true;
				toVisit.push_back(_successor);
			}
		});
	}
	return false;
}

}

CallGraph::CallGraph(ControlFlowGraphs const& _cfgs):
	m_callees(_cfgs.functionGraphs.size()),
	m_canContinue(_cfgs.functionGraphs.size(), false)
{
	for (auto const& [index, cfgPtr]: _cfgs.functionGraphs | ranges::views::enumerate)
		for (auto const& [instId, inst]: ranges::views::zip(cfgPtr->instructionIds(), cfgPtr->instructions()))
			if (inst.opcode == InstOpcode::Call)
				m_callees[index].push_back(cfgPtr->callPayload(instId).graphID);

	for (auto& callees: m_callees)
	{
		ranges::sort(callees);
		callees.erase(ranges::unique(callees), callees.end());
	}

	// least fixpoint, so that a function that only ever recurses cannot continue
	bool changed = true;
	while (changed)
	{
		changed = false;
		for (auto const& [index, cfgPtr]: _cfgs.functionGraphs | ranges::views::enumerate)
			if (!m_canContinue[index] && reachesReturn(*cfgPtr, *this))
			{
				m_canContinue[index] = true;
				changed = true;
			}
	}
}

bool CallGraph::canContinue(SSACFG const& _cfg, InstId const _inst) const
{
	if (_cfg.kindOf(_inst) == InstOpcode::Call)
		return canContinue(_cfg.callPayload(_inst).graphID);
	if (_cfg.kindOf(_inst) == InstOpcode::BuiltinCall)
		return _cfg.evmDialect.builtin(_cfg.builtinPayload(_inst).builtin).controlFlowSideEffects.canContinue;
	return true;
}

std::vector<std::vector<FunctionGraphID>> CallGraph::computeSCCs() const
{
	return solidity::util::computeStronglyConnectedComponents(m_callees);
}

bool CallGraph::isRecursive(FunctionGraphID const _function) const
{
	if (!m_recursiveFunctions)
		computeRecursiveFunctions();
	return (*m_recursiveFunctions)[_function];
}

void CallGraph::computeRecursiveFunctions() const
{
	std::vector result(m_callees.size(), false);
	for (auto const& scc: computeSCCs())
	{
		yulAssert(!scc.empty());
		if (scc.size() > 1)
			for (FunctionGraphID const f: scc)
				result[f] = true;
		else if (ranges::binary_search(m_callees[scc.front()], scc.front()))
			result[scc.front()] = true;
	}
	m_recursiveFunctions = std::move(result);
}
