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

#include <libyul/backends/evm/ssa/spill/SpillSet.h>

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>
#include <libyul/backends/evm/ssa/SSACFG.h>
#include <libyul/backends/evm/ssa/SSACFGTypes.h>
#include <libyul/backends/evm/ssa/ShadowLiveness.h>

#include <vector>

namespace solidity::yul::ssa::stack
{

/// What a predecessor hands to an edge into a block
struct IncomingEdge
{
	SSACFG::BlockId predecessor;
	/// The stack the predecessor leaves, for a conditional jump after popping the condition
	StackData stack;
};

/// Chooses the stack-in of a block from its incoming forward edges. There must be at least one incoming edge.
StackData chooseBlockStackIn(
	SSACFG const& _cfg,
	std::vector<IncomingEdge> const& _edges,
	LivenessAnalysis::LivenessData const& _liveIn,
	ShadowLiveness::ShadowSet const& _liveInShadows,
	spill::SpillSet& _spillSet,
	bool _spillingAllowed,
	std::size_t _reachableStackDepth
);

}
