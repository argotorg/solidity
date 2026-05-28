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

#include <libyul/Exceptions.h>

#include <algorithm>
#include <concepts>
#include <cstddef>
#include <limits>
#include <vector>

namespace solidity::yul::ssa::util
{

namespace detail
{

/// Callers must supply a dense `[0, N)` remapping; this struct conflates the node's
/// identity with its position in `adjacency` for performance.
template<std::unsigned_integral NodeIndex>
struct TarjanSCC
{
	static constexpr std::size_t undefined = std::numeric_limits<std::size_t>::max();

	struct Frame
	{
		NodeIndex node;
		std::size_t childIdx;
	};

	std::vector<std::vector<NodeIndex>> const& adjacency;
	/// numbers the nodes consecutively in the order in which they are discovered
	std::vector<std::size_t> discoveryIndex;
	/// lowlink[v] corresponds to the smallest index of a node reachable through v's DFS subtree
	std::vector<std::size_t> lowlink;
	std::vector<bool> onStack;
	std::vector<NodeIndex> nodeStack;
	std::vector<Frame> workStack;
	std::size_t nextIndex = 0;
	std::vector<std::vector<NodeIndex>> sccs;

	explicit TarjanSCC(std::vector<std::vector<NodeIndex>> const& _adjacency):
		adjacency(_adjacency),
		discoveryIndex(_adjacency.size(), undefined),
		lowlink(_adjacency.size(), 0),
		onStack(_adjacency.size(), false)
	{}

	void enter(NodeIndex const _v)
	{
		yulAssert(_v < adjacency.size());
		discoveryIndex[_v] = nextIndex;
		lowlink[_v] = nextIndex;
		++nextIndex;
		nodeStack.push_back(_v);
		onStack[_v] = true;
		workStack.push_back({_v, 0});
	}

	void emitSCC(NodeIndex const _root)
	{
		yulAssert(!nodeStack.empty());
		std::vector<NodeIndex> scc;
		NodeIndex w;
		do
		{
			w = nodeStack.back();
			nodeStack.pop_back();
			onStack[w] = false;
			scc.push_back(w);
		}
		while (w != _root);
		sccs.push_back(std::move(scc));
	}

	std::vector<std::vector<NodeIndex>> run() &&
	{
		for (NodeIndex root = 0; root < discoveryIndex.size(); ++root)
		{
			if (discoveryIndex[root] != undefined)
				continue;

			// start new DFS tree
			enter(root);
			while (!workStack.empty())
			{
				NodeIndex const v = workStack.back().node;
				std::size_t const childIdx = workStack.back().childIdx;
				if (childIdx < adjacency[v].size())
				{
					// process next outgoing edge
					NodeIndex const w = adjacency[v][childIdx];
					// advance v's currently handled edge before pushing w, so v resumes at the next child when w finishes
					workStack.back().childIdx = childIdx + 1;
					if (discoveryIndex[w] == undefined)
						// Successor w has not yet been visited; recurse on it
						enter(w);
					else if (onStack[w])
						// Successor w is in stack S and hence in the current SCC
						lowlink[v] = std::min(lowlink[v], discoveryIndex[w]);
				}
				else
				{
					// if v is a root node
					if (lowlink[v] == discoveryIndex[v])
						// generate an SCC and pop the node stack
						emitSCC(v);

					// pop v and propagate its lowlink to the parent (post-recursion update)
					workStack.pop_back();
					if (!workStack.empty())
					{
						NodeIndex const parent = workStack.back().node;
						lowlink[parent] = std::min(lowlink[parent], lowlink[v]);
					}
				}
			}
		}
		return std::move(sccs);
	}
};

}

/// Tarjan's strongly-connected-components algorithm.
/// Takes an adjacency list where `_adjacency[v]` is the list of successors of node `v`. Node IDs must lie in `[0, _adjacency.size())`.
/// Implementation based on the Wikipedia pseudocode.
///
/// Wikipedia contributors, "Tarjan's strongly connected components algorithm," Wikipedia, The Free Encyclopedia,
///   https://en.wikipedia.org/w/index.php?title=Tarjan%27s_strongly_connected_components_algorithm&oldid=1341352351
/// Tarjan, R.E., "Depth-First Search and Linear Graph Algorithms", https://doi.org/10.1137/0201010
template<std::unsigned_integral NodeID>
std::vector<std::vector<NodeID>> computeStronglyConnectedComponents(std::vector<std::vector<NodeID>> const& _adjacency)
{
	return detail::TarjanSCC<NodeID>(_adjacency).run();
}

}
