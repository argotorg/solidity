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

#include <libsolutil/Numeric.h>

#include <liblangutil/Exceptions.h>

#include <compare>
#include <cstddef>
#include <cstdint>
#include <limits>

namespace solidity::evmasm
{

/// Sub assembly ID representing class. Based on fixed-size 64-bit unsigned int.
/// An empty / root state is reflected by a value that is set to max and can be queried via the `empty()` member
/// function.
struct SubAssemblyID
{
	using ValueType = uint64_t;
	SubAssemblyID() = default;
	SubAssemblyID(ValueType const _value): value(_value) {}
	explicit SubAssemblyID(u256 const& _data)
	{
		solAssert(_data <= std::numeric_limits<ValueType>::max());
		value = static_cast<ValueType>(_data);
	}

	size_t asIndex() const
	{
		if constexpr(sizeof(ValueType) > sizeof(size_t))
		{
			solAssert(value < std::numeric_limits<size_t>::max());
			return static_cast<size_t>(value);
		}
		return value;
	}
	bool empty() const { return value == std::numeric_limits<ValueType>::max(); }
	auto operator<=>(SubAssemblyID const&) const = default;

	ValueType value = std::numeric_limits<ValueType>::max();
};

}
