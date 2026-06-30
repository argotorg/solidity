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

#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>
#include <libyul/backends/evm/ssa/SSACFGTypes.h>
#include <libyul/backends/evm/ssa/spill/SpillSet.h>

#include <libsolutil/Numeric.h>

#include <span>
#include <unordered_map>
#include <vector>

namespace solidity::yul::ssa::spill
{

/// Per-subobject owner of spill-memory addressing.
///
/// The ctor sums `numSpilled()` across the per-CFG `SpillSet`s, bumps `_cfgs.memoryGuard` (if any spilling is required)
/// to reserve one contiguous region for the subobject, and builds the full `(cfgIdx, InstId) -> u256 address` map.
class MemoryAddressing
{
public:
	MemoryAddressing(
		ControlFlowGraphs& _cfgs,
		std::span<SpillSet const> _spillSetsPerCFG
	);

	/// Address (within the reserved region) at which `_value` from CFG `_cfg` lives
	[[nodiscard]] u256 addressOf(FunctionGraphID _cfg, InstId _value) const;

	[[nodiscard]] bool hasAddress(FunctionGraphID _cfg, InstId _value) const;

private:
	/// m_addresses[cfgIdx][value.value] -> u256 final address
	std::vector<std::unordered_map<InstId::ValueType, u256>> m_addresses;
};

}
