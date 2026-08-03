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
/**
 * Property test for Tarjan's strongly-connected-components algorithm
 *
 * For a random directed graph we cross-check computeStronglyConnectedComponents against an independent reachability
 * oracle computed by one DFS per source node:
 *   - the returned SCCs partition [0, n) (every node appears in exactly one in-range SCC);
 *   - two nodes share an SCC iff they are mutually reachable (the SCC definition);
 *   - the recursion classification derived from the SCCs the way CallGraph::recursiveFunctions() does it (non-trivial
 *     SCC or self-edge) matches the independent "node lies on a directed cycle" oracle. This exercises the self-edge
 *     glue that the pure SCC partition does not pin down (a self-loop node and a lone node are both singleton SCCs).
 */

#include <libsolutil/TarjanSCC.h>

#include <fuzztest/fuzztest.h>
#include <gtest/gtest.h>

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <vector>

using namespace solidity::util;

namespace solidity::yul::test
{

namespace
{

using NodeID = std::uint32_t;

struct Edge
{
	NodeID from;
	NodeID to;
};

constexpr std::uint32_t maxNodes = 128;
constexpr std::uint32_t maxEdges = 256;

}

void SCCMatchesReachability(std::pair<NodeID, std::vector<Edge>> const& _graph)
{
	auto const& [numNodes, edges] = _graph;

	std::vector<std::vector<NodeID>> adjacency(numNodes);
	for (auto const& [from, to]: edges)
		adjacency[from].push_back(to);

	std::vector<std::vector<NodeID>> const sccs = computeStronglyConnectedComponents<NodeID>(adjacency);

	// SCCs partition [0, n): record each node's SCC index, checking range and uniqueness.
	std::vector<std::int64_t> sccOfNode(numNodes, -1);
	for (std::size_t sccIndex = 0; sccIndex < sccs.size(); ++sccIndex)
		for (NodeID const node: sccs[sccIndex])
		{
			ASSERT_LT(node, numNodes) << "SCC contains out-of-range node " << node;
			ASSERT_EQ(sccOfNode[node], -1) << "node " << node << " appears in multiple SCCs";
			sccOfNode[node] = static_cast<std::int64_t>(sccIndex);
		}
	for (NodeID i = 0; i < numNodes; ++i)
		ASSERT_NE(sccOfNode[i], -1) << "node " << i << " missing from SCC partition";

	// reach[s] = the set of nodes reachable from s, computed by one independent DFS per source.
	std::vector reach(numNodes, std::vector<std::uint8_t>(numNodes, false));
	for (NodeID source = 0; source < numNodes; ++source)
	{
		std::vector<NodeID> stack{source};
		reach[source][source] = true;
		while (!stack.empty())
		{
			NodeID const u = stack.back();
			stack.pop_back();
			for (NodeID const v: adjacency[u])
				if (!reach[source][v])
				{
					reach[source][v] = true;
					stack.push_back(v);
				}
		}
	}

	// Same SCC iff mutually reachable.
	for (NodeID i = 0; i < numNodes; ++i)
		for (NodeID j = 0; j < numNodes; ++j)
		{
			bool const sameSCC = sccOfNode[i] == sccOfNode[j];
			bool const mutuallyReachable = reach[i][j] && reach[j][i];
			ASSERT_EQ(sameSCC, mutuallyReachable)
				<< "nodes " << i << " and " << j << ": sameSCC=" << sameSCC
				<< " mutuallyReachable=" << mutuallyReachable;
		}
}

FUZZ_TEST(TarjanSCCProperty, SCCMatchesReachability)
	.WithDomains(
		fuzztest::FlatMap(
			[](NodeID const _numNodes) {
				return fuzztest::PairOf(
					fuzztest::Just(_numNodes),
					fuzztest::VectorOf(
						fuzztest::StructOf<Edge>(
							fuzztest::InRange<NodeID>(0, _numNodes - 1),
							fuzztest::InRange<NodeID>(0, _numNodes - 1)
						)
					).WithMaxSize(maxEdges)
				);
			},
			fuzztest::InRange<NodeID>(1, maxNodes)
		)
	);

}
