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
#include <libyul/backends/evm/ssa/stack/Shuffler.h>

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>
#include <libyul/backends/evm/ssa/SSACFG.h>
#include <libyul/backends/evm/ssa/SSACFGTypes.h>
#include <libyul/backends/evm/ssa/ShadowLiveness.h>
#include <libyul/backends/evm/ssa/StackSlot.h>

#include <vector>

namespace solidity::yul::ssa::stack
{

/// An upsilon whose copy of its input is left to the edge that its block jumps along
struct PendingCopy
{
	StackSlot shadowSlot;
	StackSlot input;
};

/// What a predecessor hands to an edge into a block
struct IncomingEdge
{
	SSACFG::BlockId predecessor;
	/// The stack the predecessor leaves, for a conditional jump after popping the condition
	StackData stack;
	/// The upsilons of the predecessor whose copy is left to the edge. No shadow slot occurs twice or on `stack`, and
	/// every input is a literal, on `stack` or spilled, which `shuffleAcrossEdge` asserts.
	std::vector<PendingCopy> pendingCopies{};
};

/// Chooses the stack-in of a block from its incoming forward edges. There must be at least one incoming edge.
StackData chooseBlockStackIn(
	SSACFG const& _cfg,
	std::vector<IncomingEdge> const& _edges,
	LivenessAnalysis::LivenessData const& _liveIn,
	ShadowLiveness::ShadowSet const& _liveInShadows,
	spill::SpillSet& _spillSet,
	bool _spillingAllowed
);

/// Shuffles the stack of `_edge` into `_stackIn`, the stack-in of the block the edge enters. `_edge` need not be one of
/// the edges the stack-in was chosen from, a back edge is not. The pending copies are made on the way: their inputs
/// are shuffled to where `_stackIn` has the shadow slots and renamed there. A pending copy whose shadow slot
/// `_stackIn` does not hold is not made; that shadow is asserted to be spilled or not in `_liveInShadows`, the
/// shadows that are live on entry to the block. A shuffle that is not admissible is returned as it is.
ShuffleResult shuffleAcrossEdge(
	IncomingEdge const& _edge,
	StackData const& _stackIn,
	ShadowLiveness::ShadowSet const& _liveInShadows,
	spill::SpillSet& _spillSet,
	bool _spillingAllowed
);

}
