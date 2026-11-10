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

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <boost/container/flat_set.hpp>

#include <vector>

namespace solidity::yul::ssa
{

namespace analysis
{
class DepthFirstSpanningTree;
}

/// The liveness of the shadows. Discovers, per block, the phis whose shadows are live on entry and on exit.
/// Shadows are not SSA values but SSU. Their liveness is computed by path exploration [1, Section 9.4].
///
/// [1] Rastello, Fabrice, and Florent Bouchez Tichadou, eds. SSA-based Compiler Design. Springer, 2022.
class ShadowLiveness
{
public:
	using ShadowSet = boost::container::flat_set<InstId>;

	explicit ShadowLiveness(analysis::DepthFirstSpanningTree const& _dfsTree);

	ShadowSet const& liveIns(SSACFG::BlockId const _blockId) const { return m_liveIns[_blockId.value]; }
	ShadowSet const& liveOuts(SSACFG::BlockId const _blockId) const { return m_liveOuts[_blockId.value]; }

private:
	std::vector<ShadowSet> m_liveIns;
	std::vector<ShadowSet> m_liveOuts;
};

}
