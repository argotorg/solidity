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

#include <libyul/backends/evm/ssa/SSACFGTypes.h>

#include <cstddef>
#include <optional>
#include <vector>

namespace solidity::yul::ssa
{

struct ControlFlowGraphs;

class CallGraph
{
public:
	explicit CallGraph(ControlFlowGraphs const& _cfgs);

	std::size_t numFunctions() const { return m_callees.size(); }

	std::vector<FunctionGraphID> const& callees(FunctionGraphID const _function) const
	{
		return m_callees[_function];
	}

	std::vector<std::vector<FunctionGraphID>> computeSCCs() const;

	/// True iff `_function` participates in a recursive chain. Either directly (self-edge) or as part of a
	/// mutual-recursion cycle of any length
	bool isRecursive(FunctionGraphID _function) const;

private:
	void computeRecursiveFunctions() const;

	std::vector<std::vector<FunctionGraphID>> m_callees;
	mutable std::optional<std::vector<bool>> m_recursiveFunctions;
};

}
