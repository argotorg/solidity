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

#include <range/v3/view/concat.hpp>

#include <cstdint>
#include <optional>
#include <vector>

namespace solidity::yul::ssa
{
/// Detect bridges according to Algorithm 1 of https://arxiv.org/pdf/2108.07346.pdf.
///
/// A bridge in an undirected graph is an edge whose removal increases the number of connected components. In control
/// flow analysis, bridge vertices are critical articulation points where removing the vertex would disconnect
/// reachable code from unreachable code. This implementation adapts the bridge-finding algorithm to directed control
/// flow graphs by treating them as undirected, then validating edge directionality to identify vertices that gate
/// access to subsequent blocks.
///
/// We use bridges to determine blocks in which it is fine to introduce junk slots on the stack at any point in time.
class BridgeFinder
{
public:
	explicit BridgeFinder(SSACFG const& _cfg):
		m_cfg(_cfg),
		m_bridgeVertex(_cfg.numBlocks()),
		m_visited(_cfg.numBlocks()),
		m_disc(_cfg.numBlocks()),
		m_low(_cfg.numBlocks())
	{
		size_t time = 0;
		dfs(time, _cfg.entry, std::nullopt);
	}

	bool bridgeVertex(SSACFG::BlockId const& _blockId) const
	{
		return m_bridgeVertex[_blockId.value];
	}

private:
	void dfs(size_t& _time, SSACFG::BlockId const& _vertex, std::optional<SSACFG::BlockId> const& _parent)
	{
		m_visited[_vertex.value] = true;
		m_disc[_vertex.value] = _time;
		m_low[_vertex.value] = _time;
		++_time;

		auto const& currentBlock = m_cfg.block(_vertex);
		currentBlock.forEachExit([&](SSACFG::BlockId const& _exit)
		{
			processNeighbor(_exit, _time, _vertex, currentBlock.entries, _parent);
		});

		for (SSACFG::BlockId const neighbor: currentBlock.entries)
			processNeighbor(neighbor, _time, _vertex, currentBlock.entries, _parent);
	}

	void processNeighbor(
		SSACFG::BlockId const& _neighbor,
		size_t& _time,
		SSACFG::BlockId const& _vertex,
		std::set<SSACFG::BlockId> const& _vertexEntries,
		std::optional<SSACFG::BlockId> const& _parent
	)
	{
		if (_neighbor == _parent)
			return;

		if (!m_visited[_neighbor.value])
		{
			dfs(_time, _neighbor, _vertex);
			m_low[_vertex.value] = std::min(m_low[_vertex.value], m_low[_neighbor.value]);
			if (m_low[_neighbor.value] > m_disc[_vertex.value])
			{
				// vertex <-> neighbor is a bridge in the undirected graph
				bool const edgeNeighborToVertex = _vertexEntries.contains(_neighbor);
				bool const edgeVertexToNeighbor = m_cfg.block(_neighbor).entries.contains(_vertex);

				// special case: if it's the entry itself, we mark it as bridge vertex (provided correct orientation),
				// so that functions which do nothing but revert have their whole tree marked as such (sans loops)
				if (!_parent)
					m_bridgeVertex[_vertex.value] = edgeVertexToNeighbor;
				// Since we are not really undirected, check if we don't have a cycle (u -> v and v -> u) and see,
				// which edge really exists here.
				// Then record the targeted vertex as bridge vertex.
				if (edgeVertexToNeighbor && !edgeNeighborToVertex)
					// bridge vertex -> neighbor
					m_bridgeVertex[_neighbor.value] = true;
				else if (edgeNeighborToVertex && !edgeVertexToNeighbor)
					// bridge neighbor -> vertex
					m_bridgeVertex[_vertex.value] = true;
			}
		}
		else
			m_low[_vertex.value] = std::min(m_low[_vertex.value], m_disc[_neighbor.value]);
	}

	SSACFG const& m_cfg;
	// determines whether a vertex is a bridge vertex. optimizing for performance over space with u8.
	std::vector<std::uint8_t> m_bridgeVertex;
	// determines whether a vertex is visited. optimizing for performance over space with u8.
	std::vector<std::uint8_t> m_visited;
	// vertex discovery time
	std::vector<std::size_t> m_disc;
	// minimum discovery time of subtree - if m_low[child] > m_low[parent], we have a bridge
	std::vector<std::size_t> m_low;
};

}
