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
 * Helpers for the memory region used to materialize common mask constants.
 */

#pragma once

#include <libsolutil/Numeric.h>

#include <cstddef>
#include <optional>

namespace solidity::evmasm
{

struct MemoryMasking
{
	static size_t constexpr zeroPointer = 0x60;
	static size_t constexpr maskPointer = 0x80;
	static size_t constexpr maskSize = 32;
	static size_t constexpr memoryStart = maskPointer + maskSize;

	/// @returns the offset in the zero/ones memory region whose MLOAD result is @a _value,
	/// if @a _value is a right-aligned byte mask wider than two bytes.
	static std::optional<size_t> offsetForRightAlignedOnes(u256 const& _value);

	/// @returns the constant produced by MLOADing at @a _offset in the zero/ones memory region.
	static std::optional<u256> constantForOffset(size_t _offset);
};

}
