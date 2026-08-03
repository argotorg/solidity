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

#include <libyul/backends/evm/ssa/StackSlot.h>

#include <fmt/format.h>

#include <cstdint>
#include <type_traits>
#include <vector>

namespace solidity::yul::ssa
{

/// A single recorded stack manipulation.
struct ShuffleOp
{
	enum class Kind: std::uint8_t
	{
		Swap,  ///< swap the top slot with the slot at depth `depth` (SWAP)
		Dup,   ///< duplicate the slot at depth `depth - 1` onto the top (DUP)
		Pop,   ///< remove the top slot (POP)
		Push,  ///< produce the freely generatable `slot` (literal, junk or function call return label) on the top
		Load,  ///< reload the spilled value `slot` from its memory slot onto the top
		Store  ///< store the spilled value `slot` into its memory slot, consuming it from the top
	};

	Kind kind = Kind::Pop;
	/// EVM instruction operand # of SWAP# / DUP#
	std::uint8_t depth = 0;
	/// Slot produced by Push / Load or consumed by Store. Junk for all other kinds.
	StackSlot slot = StackSlot::makeJunk();

	static ShuffleOp swap(StackDepth const _depth)
	{
		yulAssert(1 <= _depth.value && _depth.value <= reachableStackDepth);
		return {Kind::Swap, static_cast<std::uint8_t>(_depth.value), StackSlot::makeJunk()};
	}
	static ShuffleOp dup(StackDepth const _depth)
	{
		yulAssert(1 <= _depth.value && _depth.value <= reachableStackDepth);
		return {Kind::Dup, static_cast<std::uint8_t>(_depth.value), StackSlot::makeJunk()};
	}
	static ShuffleOp pop() { return {Kind::Pop, 0, StackSlot::makeJunk()}; }
	static ShuffleOp push(StackSlot const& _slot)
	{
		yulAssert(canBeFreelyGenerated(_slot), "only freely generatable slots can be pushed");
		return {Kind::Push, 0, _slot};
	}
	static ShuffleOp load(StackSlot const& _slot)
	{
		yulAssert(_slot.isValue() && !_slot.isLiteralValue(), "only spilled (non-literal) values can be loaded");
		return {Kind::Load, 0, _slot};
	}
	static ShuffleOp store(StackSlot const& _slot)
	{
		yulAssert(_slot.isValue() && !_slot.isLiteralValue(), "only spilled (non-literal) values can be stored");
		return {Kind::Store, 0, _slot};
	}

	bool operator==(ShuffleOp const&) const = default;
};
static_assert(std::is_trivially_copyable_v<ShuffleOp>, "Traces should be cheap to copy");

using ShuffleTrace = std::vector<ShuffleOp>;

/// Applies a single recorded operation to `_data`, reproducing the stack mutation that was recorded.
void apply(StackData& _data, ShuffleOp const& _op);
/// Replays a whole trace on `_data`.
void replay(StackData& _data, ShuffleTrace const& _trace);

}

template<>
struct fmt::formatter<solidity::yul::ssa::ShuffleOp>
{
	static auto constexpr parse(format_parse_context& ctx) -> decltype(ctx.begin()) { return ctx.begin(); }

	template<typename FormatContext>
	auto format(solidity::yul::ssa::ShuffleOp const& _op, FormatContext& _ctx) const -> decltype(_ctx.out())
	{
		using ShuffleOp = solidity::yul::ssa::ShuffleOp;
		switch (_op.kind)
		{
		case ShuffleOp::Kind::Swap:
			return fmt::format_to(_ctx.out(), "SWAP{}", _op.depth);
		case ShuffleOp::Kind::Dup:
			return fmt::format_to(_ctx.out(), "DUP{}", _op.depth);
		case ShuffleOp::Kind::Pop:
			return fmt::format_to(_ctx.out(), "POP");
		case ShuffleOp::Kind::Push:
			return fmt::format_to(_ctx.out(), "PUSH {}", solidity::yul::ssa::slotToString(_op.slot));
		case ShuffleOp::Kind::Load:
			return fmt::format_to(_ctx.out(), "LOAD {}", solidity::yul::ssa::slotToString(_op.slot));
		case ShuffleOp::Kind::Store:
			return fmt::format_to(_ctx.out(), "STORE {}", solidity::yul::ssa::slotToString(_op.slot));
		}
		solidity::util::unreachable();
	}
};
