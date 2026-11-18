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
#include <libyul/backends/evm/ssa/StackSlot.h>

#include <libyul/Exceptions.h>

#include <cstdint>
#include <deque>
#include <map>
#include <set>

namespace solidity::yul::ssa::spill
{

/// The Inst behind which a spilled variable is stored:
/// - a value behind its defining Inst (a projection behind its operation), or
/// - a shadow slot behind every upsilon that writes it, and with it the phi if the two share a memory slot
using SpillStoreSite = InstId;

/// Map associating spill store site -> spilled variable -> shuffle realizing the spill.
using SpillStoreTraces = std::map<SpillStoreSite, std::map<StackSlot, ShuffleTrace>>;

/// Per-CFG set of variables spilled to memory
class SpillSet
{
public:
	SpillSet() = default;
	/// `_phisWithOwnSlot` are the phis that are read behind one of their upsilons
	explicit SpillSet(std::set<InstId> _phisWithOwnSlot): m_phisWithOwnSlot(std::move(_phisWithOwnSlot)) {}

	/// The key under which the variable `_slot` is spilled. A shadow slot has the key of its phi, so that the two share
	/// a memory slot, unless the store behind an upsilon would overwrite the phi while it is still read.
	SpillKey keyOf(StackSlot const _slot) const
	{
		return _slot.isShadow() && !m_phisWithOwnSlot.contains(_slot.shadowPhi()) ? _slot.shadowPhiValue() : _slot;
	}

	void add(StackSlot const _slot)
	{
		SpillKey const key = keyOf(_slot);
		yulAssert(key.isVariable(), fmt::format("only variables can be spilled, not {}", key));
		bool const inserted = m_values.insert(key).second;
		yulAssert(inserted, fmt::format("can't spill a variable ({}) twice", key));
	}

	bool isSpilled(StackSlot const _slot) const { return m_values.contains(keyOf(_slot)); }

	std::size_t numSpilled() const { return m_values.size(); }

	std::set<SpillKey> const& spilledValues() const { return m_values; }

	/// Finalizes the spill set by making every spilled value's def-site `mstore` reachable.
	/// If `_storeTraces` is provided, it is rebuilt to hold each spilled value's recorded def-site store trace.
	void closeUnderReachabilityConstraints(SSACFG const& _cfg, SSACFGStackLayout const& _layout, SpillStoreTraces* _storeTraces = nullptr);

	/// Yields a copy of this spill set minus the key of `_slot`.
	[[nodiscard]] SpillSet without(StackSlot _slot) const;

private:
	/// Ensure that the variable `_slot` can be spilled at `_site`, i.e.,
	/// brought up to the top and `mstore`d. Might populate the spill set with more entries if not possible right away.
	void ensureDefSiteFeasible(StackSlot _slot, SpillStoreSite _site, StackData const& _defStack, std::deque<SpillKey>& _workQueue, SpillStoreTraces* _storeTraces);

	std::set<SpillKey> m_values;
	std::set<InstId> m_phisWithOwnSlot;
};

}
