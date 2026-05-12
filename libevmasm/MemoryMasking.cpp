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

#include <libevmasm/MemoryMasking.h>

using namespace solidity;
using namespace solidity::evmasm;

std::optional<size_t> MemoryMasking::offsetForRightAlignedOnes(u256 const& _value)
{
	u256 mask = 0;
	for (size_t bytes = 1; bytes < maskSize; ++bytes)
	{
		mask <<= 8;
		mask |= 0xff;
		if (bytes > 2 && _value == mask)
			return zeroPointer + bytes;
	}
	return std::nullopt;
}

std::optional<u256> MemoryMasking::constantForOffset(size_t _offset)
{
	if (_offset < zeroPointer || _offset > maskPointer)
		return std::nullopt;

	u256 value = 0;
	for (size_t bytes = 0; bytes < _offset - zeroPointer; ++bytes)
	{
		value <<= 8;
		value |= 0xff;
	}
	return value;
}
