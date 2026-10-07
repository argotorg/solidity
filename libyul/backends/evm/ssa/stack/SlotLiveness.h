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

#include <libyul/backends/evm/ssa/analysis/Liveness.h>
#include <libyul/backends/evm/ssa/SSACFG.h>
#include <libyul/backends/evm/ssa/stack/Stack.h>
#include <libyul/backends/evm/ssa/util/UseCountSet.h>

namespace solidity::yul::ssa::stack
{

/// Liveness counts keyed on Slot
using SlotLiveness = util::UseCountSet<Slot>;

inline SlotLiveness toSlotLiveness(SSACFG const& _cfg, analysis::Liveness::LivenessData const& _liveness)
{
	SlotLiveness::Entries entries;
	entries.reserve(_liveness.size());
	for (auto const& [valueId, count]: _liveness)
		entries.emplace_back(Slot::makeValue(_cfg, valueId), count);
	return SlotLiveness{std::move(entries)};
}

}
