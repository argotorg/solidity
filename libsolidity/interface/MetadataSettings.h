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

#include <liblangutil/Exceptions.h>

namespace solidity::frontend
{

/// Known metadata hashing methods.
enum class MetadataHash { IPFS, Bzzr1, None };

/// @param _metadataHash The metadata hash string to convert.
/// @return The corresponding MetadataHash enum value, or `MetadataHash::None` for unknown strings.
inline MetadataHash metadataHashFromString(std::string const& _metadataHash)
{
	if (_metadataHash == "ipfs")
		return MetadataHash::IPFS;
	if (_metadataHash == "bzzr1")
		return MetadataHash::Bzzr1;
	return MetadataHash::None;
}

/// @param _metadataHash The metadata hash enum value to convert to string.
/// @return The string representation of the metadata hash.
inline std::string metadataHashToString(MetadataHash const& _metadataHash)
{
	switch (_metadataHash)
	{
	case MetadataHash::IPFS:
		return "ipfs";
	case MetadataHash::Bzzr1:
		return "bzzr1";
	case MetadataHash::None:
		return "none";
	default:
		solAssert(false, "Unknown metadata hash enum value");
	}
}

}

