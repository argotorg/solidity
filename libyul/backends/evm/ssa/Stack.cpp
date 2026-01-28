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

#include <libyul/backends/evm/ssa/Stack.h>

#include <fmt/ranges.h>

#include <range/v3/view/drop.hpp>
#include <range/v3/view/take_while.hpp>

namespace
{
size_t junkTailSize(solidity::yul::ssa::StackData const& _stackData)
{
	auto junkTail = _stackData | ranges::views::take_while([](auto const& slot) { return slot.isJunk(); });
	return static_cast<size_t>(ranges::distance(junkTail));
}
}

namespace solidity::yul::ssa
{

std::string slotToString(StackSlot const& _slot)
{
	switch (_slot.kind())
	{
	case StackSlot::Kind::ValueID:
		if (_slot.isLiteralValueID())
			return fmt::format("lit{}", _slot.valueID().value());
		else
			return fmt::format("v{}", _slot.valueID().value());
	case StackSlot::Kind::Junk:
		return "JUNK";
	case StackSlot::Kind::FunctionCallReturnLabel:
		return fmt::format("FunctionCallReturnLabel[{}]", _slot.functionCallReturnLabel());
	case StackSlot::Kind::FunctionReturnLabel:
		return fmt::format("ReturnLabel[{}]", _slot.functionReturnLabel());
	}
	util::unreachable();
}

std::string slotToString(StackSlot const& _slot, SSACFG const& _cfg)
{
	if (_slot.kind() == StackSlot::Kind::ValueID)
		return _slot.valueID().str(_cfg);

	return slotToString(_slot);
}

std::string stackToString(StackData const& _stackData)
{
	auto const numJunk = junkTailSize(_stackData);
	if (numJunk > 0)
		return fmt::format(
			"[JUNK x {}, {}]",
			numJunk,
			fmt::join(_stackData | ranges::views::drop(numJunk) | ranges::views::transform([&](auto const& _slot) { return slotToString(_slot); }), ", ")
		);

	return fmt::format(
		"[{}]",
		fmt::join(_stackData | ranges::views::transform([&](auto const& _slot) { return slotToString(_slot); }), ", ")
	);
}

std::string stackToString(StackData const& _stackData, SSACFG const& _cfg)
{
	auto const numJunk = junkTailSize(_stackData);
	if (numJunk > 0)
		return fmt::format(
			"[JUNK x {}, {}]",
			numJunk,
			fmt::join(_stackData | ranges::views::drop(numJunk) | ranges::views::transform([&](auto const& _slot) { return slotToString(_slot, _cfg); }), ", ")
		);

	return fmt::format(
		"[{}]",
		fmt::join(_stackData | ranges::views::transform([&](auto const& _slot) { return slotToString(_slot, _cfg); }), ", ")
	);
}

}
