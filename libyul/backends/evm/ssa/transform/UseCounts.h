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
 * Per-InstId use counts..
 */
#pragma once

#include <libyul/backends/evm/ssa/SSACFGTypes.h>

#include <libyul/Exceptions.h>

#include <cstdint>
#include <vector>

namespace solidity::yul::ssa
{

class SSACFG;

namespace transform
{

/// Determines how often each InstId is read.
/// A use is an occurrence of the id in another instruction's inputs.
/// An Upsilon's target phi is a def-site back-link, not a use.
class UseCounts
{
public:
	explicit UseCounts(SSACFG const& _cfg);

	/// Number of reads of `_id`.
	std::uint32_t numUses(InstId const _id) const
	{
		yulAssert(_id.value < m_counts.size());
		return m_counts[_id.value];
	}
	bool hasSingleUse(InstId const _id) const { return numUses(_id) == 1; }

private:
	std::vector<std::uint32_t> m_counts;
};

}

}
