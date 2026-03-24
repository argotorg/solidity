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
/**
 * Lightweight ID types used throughout the SSA CFG.
 */

#pragma once

#include <libsolutil/Assertions.h>

#include <fmt/format.h>

#include <cstdint>
#include <limits>
#include <string>

namespace solidity::yul::ssa
{

class SSACFG;

struct BlockId
{
	using ValueType = std::uint32_t;
	ValueType value = std::numeric_limits<ValueType>::max();
	bool hasValue() const { return value != std::numeric_limits<ValueType>::max(); }
	auto operator<=>(BlockId const&) const = default;
};

struct OperationId
{
	using ValueType = std::uint32_t;
	ValueType value = std::numeric_limits<ValueType>::max();
	bool hasValue() const { return value != std::numeric_limits<ValueType>::max(); }
	auto operator<=>(OperationId const&) const = default;
};

class ValueId
{
public:
	enum class Kind: std::uint8_t
	{
		Literal,
		Variable,
		Phi,
		Unreachable
	};
	using ValueType = std::uint32_t;

	constexpr ValueId() = default;
	constexpr ValueId(ValueType const _value, Kind const _kind): m_value(_value), m_kind(_kind) {}
	constexpr ValueId(ValueId const&) = default;
	constexpr ValueId(ValueId&&) = default;
	constexpr ValueId& operator=(ValueId const&) = default;
	constexpr ValueId& operator=(ValueId&&) = default;

	static ValueId constexpr makeLiteral(ValueType const& _value) { return ValueId{_value, Kind::Literal}; }
	static ValueId constexpr makeVariable(ValueType const& _value) { return ValueId{_value, Kind::Variable}; }
	static ValueId constexpr makePhi(ValueType const& _value) { return ValueId{_value, Kind::Phi}; }
	static ValueId constexpr makeUnreachable() { return ValueId{0u, Kind::Unreachable}; }

	bool constexpr isLiteral() const noexcept { return m_kind == Kind::Literal; }
	bool constexpr isVariable() const noexcept { return m_kind == Kind::Variable; }
	bool constexpr isPhi() const noexcept { return m_kind == Kind::Phi; }
	bool constexpr isUnreachable() const noexcept { return m_kind == Kind::Unreachable; }

	bool constexpr hasValue() const { return m_value != std::numeric_limits<ValueType>::max(); }
	ValueType constexpr value() const noexcept { return m_value; }
	Kind constexpr kind() const noexcept { return m_kind; }

	/// Returns a human-readable string representation. Requires the full SSACFG for literal values.
	std::string str(SSACFG const& _cfg) const;

	auto operator<=>(ValueId const&) const = default;

private:
	ValueType m_value{std::numeric_limits<ValueType>::max()};
	Kind m_kind{Kind::Unreachable};
};

}

template<>
struct fmt::formatter<solidity::yul::ssa::BlockId>
{
	static auto constexpr parse(format_parse_context& ctx) -> decltype(ctx.begin()) { return ctx.begin(); }

	template<typename FormatContext>
	auto format(solidity::yul::ssa::BlockId const& _blockId, FormatContext& _ctx) const -> decltype(_ctx.out())
	{
		if (!_blockId.hasValue())
			return fmt::format_to(_ctx.out(), "empty");
		return fmt::format_to(_ctx.out(), "{}", _blockId.value);
	}
};

template<>
struct fmt::formatter<solidity::yul::ssa::OperationId>
{
	static auto constexpr parse(format_parse_context& ctx) -> decltype(ctx.begin()) { return ctx.begin(); }

	template<typename FormatContext>
	auto format(solidity::yul::ssa::OperationId const& _opId, FormatContext& _ctx) const -> decltype(_ctx.out())
	{
		if (!_opId.hasValue())
			return fmt::format_to(_ctx.out(), "empty");
		return fmt::format_to(_ctx.out(), "op{}", _opId.value);
	}
};

template<>
struct fmt::formatter<solidity::yul::ssa::ValueId>
{
	static auto constexpr parse(format_parse_context& ctx) -> decltype(ctx.begin()) { return ctx.begin(); }

	template<typename FormatContext>
	auto format(solidity::yul::ssa::ValueId const& _valueId, FormatContext& _ctx) const -> decltype(_ctx.out())
	{
		if (!_valueId.hasValue())
			return fmt::format_to(_ctx.out(), "empty");
		switch (_valueId.kind())
		{
		case solidity::yul::ssa::ValueId::Kind::Literal:
			return fmt::format_to(_ctx.out(), "lit{}", _valueId.value());
		case solidity::yul::ssa::ValueId::Kind::Variable:
			return fmt::format_to(_ctx.out(), "v{}", _valueId.value());
		case solidity::yul::ssa::ValueId::Kind::Phi:
			return fmt::format_to(_ctx.out(), "phi{}", _valueId.value());
		case solidity::yul::ssa::ValueId::Kind::Unreachable:
			return fmt::format_to(_ctx.out(), "unreachable");
		}
		solidity::util::unreachable();
	}
};
