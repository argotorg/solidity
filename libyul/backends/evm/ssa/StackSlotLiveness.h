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

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>
#include <libyul/backends/evm/ssa/SSACFG.h>
#include <libyul/backends/evm/ssa/Stack.h>
#include <libyul/backends/evm/ssa/util/UseCountSet.h>

namespace solidity::yul::ssa
{

/// Liveness counts keyed on StackSlot
using StackSlotLiveness = util::UseCountSet<StackSlot>;

inline StackSlotLiveness toStackSlotLiveness(SSACFG const& _cfg, LivenessAnalysis::LivenessData const& _liveness)
{
	StackSlotLiveness::Entries entries;
	entries.reserve(_liveness.size());
	for (auto const& [valueId, count]: _liveness)
		entries.emplace_back(StackSlot::makeValue(_cfg, valueId), count);
	return StackSlotLiveness{std::move(entries)};
}

}
