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

#include <libyul/backends/evm/ssa/SSACFGTopologicalSort.h>
#include <libyul/backends/evm/ssa/SSACFG.h>

#include <libsolutil/DisjointSet.h>

#include <cstddef>
#include <set>
#include <vector>

namespace solidity::yul::ssa
{

/// Constructs a loop nesting forest for an SSACFG using Tarjan's algorithm [1].
///
/// [1] Ramalingam, Ganesan. "Identifying loops in almost linear time."
///     ACM Transactions on Programming Languages and Systems (TOPLAS) 21.2 (1999): 175-188.
class SSACFGLoopNestingForest
{
	using BlockIdValue = SSACFG::BlockId::ValueType;

public:
	explicit SSACFGLoopNestingForest(ForwardSSACFGTopologicalSort const& _sort);

	/// blocks which are not contained in a loop get assigned the loop parent numeric_limit<size_t>::max()
	std::vector<BlockIdValue> const& loopParents() const { return m_loopParents; }
	/// all loop nodes (entry blocks for loops), also nested ones
	std::set<BlockIdValue> const& loopNodes() const { return m_loopNodes; }
	/// root loop nodes in the forest for outer-most loops
	std::set<BlockIdValue> const& loopRootNodes() const { return m_loopRootNodes; }
private:
	void findLoop(BlockIdValue _potentialHeader);
	void collapse(std::set<BlockIdValue> const& _loopBody, BlockIdValue _loopHeader);

	ForwardSSACFGTopologicalSort const& m_sort;
	SSACFG const& m_cfg;

	util::ContiguousDisjointSet<BlockIdValue> m_vertexPartition;
	std::vector<BlockIdValue> m_loopParents;
	std::set<BlockIdValue> m_loopNodes;
	std::set<BlockIdValue> m_loopRootNodes;
};

}
