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
#include <libyul/backends/evm/ssa/util/TarjanSCC.h>

#include <libyul/Exceptions.h>

#include <range/v3/algorithm/binary_search.hpp>
#include <range/v3/algorithm/sort.hpp>
#include <range/v3/algorithm/unique.hpp>
#include <range/v3/view/enumerate.hpp>
#include <range/v3/view/zip.hpp>

solidity::yul::ssa::CallGraph::CallGraph(ControlFlowGraphs const& _cfgs): m_callees(_cfgs.functionGraphs.size())
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
}

std::vector<std::vector<solidity::yul::ssa::FunctionGraphID>> solidity::yul::ssa::CallGraph::computeSCCs() const
{
	return util::computeStronglyConnectedComponents(m_callees);
}

bool solidity::yul::ssa::CallGraph::isRecursive(FunctionGraphID const _function) const
{
	if (!m_recursiveFunctions)
		computeRecursiveFunctions();
	return (*m_recursiveFunctions)[_function];
}

void solidity::yul::ssa::CallGraph::computeRecursiveFunctions() const
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
