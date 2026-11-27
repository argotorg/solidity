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

#include <libyul/Exceptions.h>

#include <concepts>
#include <cstddef>
#include <cstdint>
#include <iterator>
#include <utility>
#include <vector>

namespace solidity::yul::ssa::util
{

enum class TraversalOrder
{
	DepthFirst,
	BreadthFirst
};

/// A function that tells a traversal where to go on from a block
template<typename T>
concept NeighborFunction = std::invocable<T&, BlockId, void(&)(BlockId)>;

/// Lazy single-pass range over the blocks that a traversal reaches from its roots
template<NeighborFunction ForEachNeighbor>
class BlockTraversal
{
public:
	class Iterator
	{
	public:
		using value_type = BlockId;
		using difference_type = std::ptrdiff_t;

		Iterator() = default;
		explicit Iterator(BlockTraversal& _traversal): m_traversal(&_traversal) {}

		BlockId operator*() const { return m_traversal->m_current; }
		Iterator& operator++()
		{
			m_traversal->advance();
			return *this;
		}
		void operator++(int) { ++*this; }
		bool operator==(std::default_sentinel_t) const { return !m_traversal->m_current.hasValue(); }

	private:
		BlockTraversal* m_traversal = nullptr;
	};

	template<InputRangeOf<BlockId> Roots>
	BlockTraversal(
		std::size_t const _numBlocks,
		Roots const& _roots,
		ForEachNeighbor _forEachNeighbor,
		TraversalOrder const _order = TraversalOrder::DepthFirst
	):
		m_forEachNeighbor(std::move(_forEachNeighbor)),
		m_order(_order),
		m_discovered(_numBlocks, false)
	{
		for (BlockId const root: _roots)
			discover(root);
		moveToNextPending();
	}

	// The iterators refer to the traversal.
	BlockTraversal(BlockTraversal const&) = delete;
	BlockTraversal& operator=(BlockTraversal const&) = delete;

	Iterator begin() { return Iterator(*this); }
	std::default_sentinel_t end() const { return std::default_sentinel; }

	/// Whether the traversal reaches `_block`
	bool contains(BlockId const _block)
	{
		while (m_current.hasValue())
			advance();
		yulAssert(_block.value < m_discovered.size());
		return m_discovered[_block.value];
	}

private:
	void discover(BlockId const _block)
	{
		yulAssert(_block.value < m_discovered.size());
		if (m_discovered[_block.value])
			return;
		m_discovered[_block.value] = true;
		m_pending.push_back(_block);
	}

	void advance()
	{
		m_forEachNeighbor(m_current, [this](BlockId const _neighbor) { discover(_neighbor); });
		moveToNextPending();
	}

	void moveToNextPending()
	{
		if (m_firstPending == m_pending.size())
			m_current = BlockId{};
		else if (m_order == TraversalOrder::BreadthFirst)
			m_current = m_pending[m_firstPending++];
		else
		{
			m_current = m_pending.back();
			m_pending.pop_back();
		}
	}

	ForEachNeighbor m_forEachNeighbor;
	TraversalOrder m_order;
	std::vector<std::uint8_t> m_discovered;
	std::vector<BlockId> m_pending;
	std::size_t m_firstPending = 0;
	BlockId m_current{};
};

}
