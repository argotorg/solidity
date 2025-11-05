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

#include <libsolutil/DisjointSet.h>

#include <liblangutil/Exceptions.h>

#include <numeric>

using namespace solidity::util;

template<typename ValueType>
ContiguousDisjointSet<ValueType>::ContiguousDisjointSet(size_t const _numNodes):
	m_parents(_numNodes),
	m_neighbors(_numNodes),
	m_sizes(_numNodes, static_cast<value_type>(1)),
	m_numSets(_numNodes)
{
	// each is their own neighbor and parent
	std::iota(m_parents.begin(), m_parents.end(), 0);
	std::iota(m_neighbors.begin(), m_neighbors.end(), 0);
}

template<typename ValueType>
size_t ContiguousDisjointSet<ValueType>::numSets() const { return m_numSets; }

template<typename ValueType>
typename ContiguousDisjointSet<ValueType>::value_type ContiguousDisjointSet<ValueType>::find(value_type const _element) const
{
	solAssert(_element < m_parents.size());
	// path halving
	value_type rootElement = _element;
	while (rootElement != m_parents[rootElement])
	{
		m_parents[rootElement] = m_parents[m_parents[rootElement]];
		rootElement = m_parents[rootElement];
	}
	return rootElement;
}

template<typename ValueType>
void ContiguousDisjointSet<ValueType>::merge(value_type const _x, value_type const _y, bool const _mergeBySize)
{
	auto xRoot = find(_x);
	auto yRoot = find(_y);

	if (xRoot == yRoot)
		return;  // we're done, nothing to merge here

	// if merge by size: merge smaller (yRoot) into larger (xRoot) subset;
	// otherwise if _x is the representative of subset(_x), it will stay representative
	if (_mergeBySize && m_sizes[xRoot] < m_sizes[yRoot])
		std::swap(xRoot, yRoot);

	m_parents[yRoot] = xRoot;
	m_sizes[xRoot] += m_sizes[yRoot];
	std::swap(m_neighbors[xRoot], m_neighbors[yRoot]);
	--m_numSets;
}

template<typename ValueType>
bool ContiguousDisjointSet<ValueType>::sameSubset(value_type const _x, value_type const _y) const
{
	return find(_x) == find(_y);
}

template<typename ValueType>
typename  ContiguousDisjointSet<ValueType>::size_type ContiguousDisjointSet<ValueType>::sizeOfSubset(value_type const _x) const
{
	return m_sizes[find(_x)];
}

template<typename ValueType>
std::set<typename ContiguousDisjointSet<ValueType>::value_type> ContiguousDisjointSet<ValueType>::subset(value_type const _x) const
{
	solAssert(_x < m_parents.size());
	std::set<value_type> result{_x};
	value_type neighbor = m_neighbors[_x];
	while (neighbor != _x)
	{
		result.insert(neighbor);
		neighbor = m_neighbors[neighbor];
	}
	return result;
}

template<typename ValueType>
std::vector<std::set<typename ContiguousDisjointSet<ValueType>::value_type>> ContiguousDisjointSet<ValueType>::subsets() const
{
	std::vector<std::set<value_type>> result;
	std::vector<std::uint8_t> visited(m_parents.size(), false);
	for (value_type x = 0; x < m_parents.size(); ++x)
	{
		auto xRoot = find(x);
		if (!visited[xRoot])
		{
			result.push_back(subset(xRoot));
			visited[xRoot] = true;
		}
	}
	return result;
}

template class solidity::util::ContiguousDisjointSet<std::uint32_t>;
