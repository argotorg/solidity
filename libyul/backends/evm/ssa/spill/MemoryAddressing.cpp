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

#include <libyul/backends/evm/ssa/spill/MemoryAddressing.h>

#include <libyul/Exceptions.h>

#include <cstdint>

using namespace solidity::yul::ssa::spill;


MemoryAddressing::MemoryAddressing(ControlFlowGraphs& _cfgs, std::span<SpillSet const> _spillSetsPerCFG):
	m_addresses(_spillSetsPerCFG.size())
{
	yulAssert(_spillSetsPerCFG.size() == _cfgs.functionGraphs.size());

	std::size_t totalSlots = 0;
	for (auto const& spillSet: _spillSetsPerCFG)
		totalSlots += spillSet.numSpilled();

	if (totalSlots == 0)
		return;

	yulAssert(
		_cfgs.memoryGuard.has_value(),
		"Spilling requires a memoryguard boundary, but none is set for this subobject."
	);
	u256 const originalGuard = *_cfgs.memoryGuard;
	*_cfgs.memoryGuard += u256(totalSlots) * 32;

	std::uint32_t globalSlot = 0;
	for (std::size_t i = 0; i < _spillSetsPerCFG.size(); ++i)
	{
		auto const& spillSet = _spillSetsPerCFG[i];
		auto& cfgMap = m_addresses[i];
		cfgMap.reserve(spillSet.numSpilled());
		for (InstId const value: spillSet.spilledValues())
			cfgMap.emplace(value.value, originalGuard + u256(32) * globalSlot++);
	}
	yulAssert(globalSlot == totalSlots);
}

solidity::u256 MemoryAddressing::addressOf(FunctionGraphID _cfg, InstId _value) const
{
	yulAssert(_cfg < m_addresses.size(), fmt::format("CFG index out of range: {}", _cfg));
	auto const& cfgMap = m_addresses[_cfg];
	auto const it = cfgMap.find(_value.value);
	yulAssert(it != cfgMap.end(), fmt::format("not spilled: cfg={} value={}", _cfg, _value));
	return it->second;
}
bool MemoryAddressing::hasAddress(FunctionGraphID _cfg, InstId const _value) const
{
	yulAssert(_cfg < m_addresses.size(), fmt::format("CFG index out of range: {}", _cfg));
	auto const& cfgMap = m_addresses[_cfg];
	return cfgMap.contains(_value.value);
}
