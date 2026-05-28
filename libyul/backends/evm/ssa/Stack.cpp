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

#include <range/v3/view/transform.hpp>

#include <fmt/format.h>
#include <fmt/ranges.h>

namespace solidity::yul::ssa
{

std::string slotToString(StackSlot const& _slot)
{
	switch (_slot.kind())
	{
	case StackSlot::Kind::Value:
		if (_slot.isLiteralValue())
			return fmt::format("lit{}", _slot.value().value);
		if (_slot.isPhiValue())
			return fmt::format("phi{}", _slot.value().value);
		return fmt::format("{}", _slot.value());
	case StackSlot::Kind::Junk:
		return "JUNK";
	case StackSlot::Kind::FunctionCallReturnLabel:
		return fmt::format("FunctionCallReturnLabel[{}]", _slot.functionCallReturnLabel());
	case StackSlot::Kind::FunctionReturnLabel:
		return fmt::format("ReturnLabel[{}]", _slot.functionReturnLabel());
	}
	solidity::util::unreachable();
}

std::string stackToString(StackData const& _stackData)
{
	return fmt::format(
		"[{}]",
		fmt::join(_stackData | ranges::views::transform([&](auto const& _slot) { return slotToString(_slot); }), ", ")
	);
}

}
