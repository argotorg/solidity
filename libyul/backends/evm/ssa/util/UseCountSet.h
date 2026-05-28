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

#include <range/v3/range/concepts.hpp>
#include <range/v3/range/traits.hpp>

#include <algorithm>
#include <concepts>
#include <cstdint>
#include <iterator>
#include <utility>
#include <vector>

namespace solidity::yul::ssa::util
{

/// Vector-backed reference-counted set keyed on `Key`. Each entry carries a non-zero use count; absent keys have
/// effective count 0. Designed for small working sets such that linear scan beats the constant overhead
/// of a hashed or tree-based associative container.
template <std::equality_comparable Key>
class UseCountSet
{
public:
	using Value = Key;
	using Count = std::uint32_t;
	using Entries = std::vector<std::pair<Key, Count>>;

	UseCountSet() = default;
	template<std::input_iterator Iter, std::sentinel_for<Iter> Sentinel>
	UseCountSet(Iter _begin, Sentinel _end): m_entries(_begin, _end) {}
	explicit UseCountSet(Entries _entries): m_entries(std::move(_entries)) {}

	bool contains(Key const& _key) const
	{
		return findEntry(_key) != m_entries.end();
	}
	Count count(Key const& _key) const
	{
		auto const it = findEntry(_key);
		return it == m_entries.end() ? Count{0} : it->second;
	}
	typename Entries::const_iterator begin() const { return m_entries.begin(); }
	typename Entries::const_iterator end() const { return m_entries.end(); }
	typename Entries::size_type size() const { return m_entries.size(); }
	bool empty() const { return m_entries.empty(); }

	/// Add `_count` to existing entry or insert a new one. No-op if `_count == 0`.
	void insert(Key const& _key, Count _count = 1)
	{
		if (_count == 0)
			return;
		auto it = findEntry(_key);
		if (it != m_entries.end())
			it->second += _count;
		else
			m_entries.emplace_back(_key, _count);
	}

	/// Remove the entry for `_key` if present.
	void erase(Key const& _key)
	{
		if (auto const it = findEntry(_key); it != m_entries.end())
			m_entries.erase(it);
	}

	/// Subtract `_count` from the entry for `_key`, removing it if the count
	/// drops to zero. No-op if `_key` is absent or `_count == 0`.
	void remove(Key const& _key, Count _count = 1)
	{
		if (_count == 0)
			return;
		auto it = findEntry(_key);
		if (it == m_entries.end())
			return;
		if (it->second <= _count)
			m_entries.erase(it);
		else
			it->second -= _count;
	}

	/// Sum-merge counts from `_other` into this.
	UseCountSet& operator+=(UseCountSet const& _other)
	{
		for (auto const& [key, count]: _other.m_entries)
			insert(key, count);
		return *this;
	}

	/// Union with `_other`, taking max count per key.
	UseCountSet& maxUnion(UseCountSet const& _other)
	{
		for (auto const& [key, count]: _other.m_entries)
		{
			auto it = findEntry(key);
			if (it != m_entries.end())
				it->second = std::max(it->second, count);
			else
				m_entries.emplace_back(key, count);
		}
		return *this;
	}

	void insertAll(ranges::input_range auto&& _values) requires std::convertible_to<ranges::range_reference_t<decltype(_values)>, Key>
	{
		for (auto const& value: _values)
			insert(value);
	}

	void eraseAll(ranges::input_range auto&& _values) requires std::convertible_to<ranges::range_reference_t<decltype(_values)>, Key>
	{
		for (auto const& value: _values)
			erase(value);
	}

	template<typename Predicate>
	void eraseIf(Predicate&& _predicate)
	{
		std::erase_if(m_entries, std::forward<Predicate>(_predicate));
	}

private:
	typename Entries::iterator findEntry(Key const& _key)
	{
		return std::find_if(m_entries.begin(), m_entries.end(), [&](auto const& _entry) { return _entry.first == _key; });
	}
	typename Entries::const_iterator findEntry(Key const& _key) const
	{
		return std::find_if(m_entries.begin(), m_entries.end(), [&](auto const& _entry) { return _entry.first == _key; });
	}

	Entries m_entries;
};

}
