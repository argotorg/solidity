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

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <cstddef>
#include <set>
#include <vector>

namespace solidity::yul::ssa
{

/// Performs a topological sort on the forward CFG (no back/cross edges)
class ForwardSSACFGTopologicalSort
{
public:
	explicit ForwardSSACFGTopologicalSort(SSACFG const& _cfg);

	std::vector<SSACFG::BlockId::ValueType> const& preOrder() const { return m_preOrder; }
	std::vector<SSACFG::BlockId::ValueType> const& postOrder() const { return m_postOrder; }
	std::set<SSACFG::BlockId::ValueType> const& backEdgeTargets() const { return m_backEdgeTargets; }
	SSACFG const& cfg() const { return m_cfg; }
	bool backEdge(SSACFG::BlockId const& _block1, SSACFG::BlockId const& _block2) const;
	SSACFG::BlockId::ValueType preOrderIndexOf(SSACFG::BlockId::ValueType _block) const { return m_blockWisePreOrder[_block]; }
	SSACFG::BlockId::ValueType maxSubtreePreOrderIndexOf(SSACFG::BlockId::ValueType _block) const { return m_blockWiseMaxSubtreePreOrder[_block]; }

private:
	void dfs(SSACFG::BlockId::ValueType _vertex);
	/// Checks if block1 is an ancestor of block2, ie there's a path from block1 to block2 in the dfs tree
	bool ancestor(SSACFG::BlockId::ValueType _block1, SSACFG::BlockId::ValueType _block2) const;

	SSACFG const& m_cfg;
	std::vector<char> m_explored{};
	std::vector<SSACFG::BlockId::ValueType> m_postOrder{};
	std::vector<SSACFG::BlockId::ValueType> m_preOrder{};
	std::vector<SSACFG::BlockId::ValueType> m_blockWisePreOrder{};
	std::vector<SSACFG::BlockId::ValueType> m_blockWiseMaxSubtreePreOrder{};
	std::vector<std::tuple<SSACFG::BlockId::ValueType, SSACFG::BlockId::ValueType>> m_potentialBackEdges{};
	std::set<SSACFG::BlockId::ValueType> m_backEdgeTargets{};
};
}
