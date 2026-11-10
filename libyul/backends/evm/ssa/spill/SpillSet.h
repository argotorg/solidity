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
#include <utility>
#include <variant>
#include <vector>

namespace solidity::yul::ssa::spill
{

/// Where a spilled variable is stored:
/// - a value other than a phi behind its defining Inst (a projection behind its operation), and a function argument
///   on function entry (denoted by the Inst it is stored behind), or
/// - a phi, through its shadow slot, on entry of every block whose incoming edges write the shadow slot (by the block)
using SpillStoreSite = std::variant<BlockId, InstId>;

/// Per site, for each variable stored there the recorded shuffle realizing its store: brings the variable to the
/// stack top and concludes with the `Store` op consuming it.
using SpillStoreTraces = std::map<SpillStoreSite, std::map<StackSlot, ShuffleTrace>>;

/// Per-CFG set of variables spilled to memory
class SpillSet
{
public:
	/// The key under which the variable `_slot` is spilled. A phi's shadow slot shares the phi's key.
	static SpillKey keyOf(StackSlot const _slot) {
		return _slot.isShadow() ? _slot.shadowPhiValue() : _slot;
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
};

}
