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
#include <libyul/backends/evm/ssa/ShuffleTrace.h>

#include <libyul/Exceptions.h>

#include <cstdint>
#include <deque>
#include <map>
#include <set>

namespace solidity::yul::ssa::spill
{

/// Per spilled value the recorded shuffle realizing its def-site store: brings the value to the stack top and
/// concludes with the `Store` op consuming it.
using SpillStoreTraces = std::map<InstId, ShuffleTrace>;

/// Per-CFG set of SSA values spilled to memory
class SpillSet
{
public:
	void add(InstId const _value)
	{
		bool const inserted = m_values.insert(_value).second;
		yulAssert(inserted, fmt::format("can't spill a value ({}) twice", _value));
	}

	bool isSpilled(InstId const _value) const { return m_values.contains(_value); }

	std::size_t numSpilled() const { return m_values.size(); }

	std::set<InstId> const& spilledValues() const { return m_values; }

	/// Finalizes the spill set by making every spilled value's def-site `mstore` reachable.
	/// If `_storeTraces` is provided, it is rebuilt to hold each spilled value's recorded def-site store trace.
	void closeUnderReachabilityConstraints(SSACFG const& _cfg, SSACFGStackLayout const& _layout, SpillStoreTraces* _storeTraces = nullptr);

	/// Yields a copy of this spill set minus `_id`.
	[[nodiscard]] SpillSet without(InstId _id) const;

private:
	/// Ensure that the value `_value` can be spilled with respect to `_defStack`, i.e., brought up to the top
	/// and `mstore`d. Might populate the spill set with more entries if not possible right away.
	void ensureDefSiteFeasible(SSACFG const& _cfg, InstId _value, StackData const& _defStack, std::deque<InstId>& _workQueue, SpillStoreTraces* _storeTraces);

	std::set<InstId> m_values;
};

}
