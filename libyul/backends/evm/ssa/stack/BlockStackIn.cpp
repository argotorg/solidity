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

#include <libyul/backends/evm/ssa/stack/BlockStackIn.h>

#include <libyul/backends/evm/ssa/stack/Shuffler.h>

#include <libyul/backends/evm/ssa/Stack.h>
#include <libyul/backends/evm/ssa/StackUtils.h>

#include <tuple>

using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::stack;

namespace
{
void declareJunk(
	Stack& _stack,
	LivenessAnalysis::LivenessData const& _live,
	ShadowLiveness::ShadowSet const& _liveShadows
)
{
	for (StackOffset offset{0}; offset < _stack.size(); ++offset.value)
	{
		auto const& slot = _stack[offset];
		if (
			(slot.isValue() && !_live.contains(slot.value())) ||
			(slot.isShadow() && !_liveShadows.contains(slot.shadowPhi()))
		)
			_stack.declareJunk(offset);
	}
}

}

StackData stack::chooseBlockStackIn(
	SSACFG const& _cfg,
	std::vector<IncomingEdge> const& _edges,
	LivenessAnalysis::LivenessData const& _liveIn,
	ShadowLiveness::ShadowSet const& _liveInShadows,
	spill::SpillSet& _spillSet,
	bool const _spillingAllowed
)
{
	yulAssert(!_edges.empty());
	StackData stackIn;
	// The chosen stack-in only affects code quality since every incoming edge is shuffled to it
	if (_edges.size() == 1)
	{
		// pass through
		stackIn = _edges[0].stack;
		Stack stack(stackIn);
		declareJunk(stack, _liveIn, _liveInShadows);
	}
	else
	{
		// Pre-compute each parent's proposal
		std::vector<StackData> proposals(_edges.size());
		for (std::size_t i = 0; i < _edges.size(); ++i)
		{
			proposals[i] = _edges[i].stack;
			{
				Stack stack(proposals[i]);
				declareJunk(stack, _liveIn, _liveInShadows);
			}
		}
		// For each candidate stack-in layout (one parent's proposal), reconcile every parent to it,
		// discovering the spills needed to make each reconciliation realizable
		std::vector<std::size_t> cumulativeGas(_edges.size(), 0);
		std::vector<spill::SpillSet> candidateSpillSets(_edges.size());
		for (std::size_t i = 0; i < _edges.size(); ++i)
		{
			spill::SpillSet candidateSpillSet = _spillSet;
			for (std::size_t j = 0; j < _edges.size(); ++j)
			{
				StackData edgeStack = _edges[j].stack;
				ShuffleResult const result = stack::shuffle(
					edgeStack,
					proposals[i],
					candidateSpillSet,
					_spillingAllowed
				);
				yulAssert(result.status == ShuffleResult::Status::Admissible);
				cumulativeGas[i] += stackOpsGas(_cfg, result.trace);
			}
			candidateSpillSets[i] = std::move(candidateSpillSet);
		}
		// Pick the candidate that spills the least; break ties by gas, then by preferring smaller stacks.
		auto const candidateCost = [&](std::size_t const _i) {
			return std::make_tuple(candidateSpillSets[_i].numSpilled(), cumulativeGas[_i], proposals[_i].size());
		};
		std::size_t best = 0;
		for (std::size_t i = 1; i < _edges.size(); ++i)
			if (candidateCost(i) < candidateCost(best))
				best = i;
		yulAssert(
			_spillingAllowed || candidateSpillSets[best].numSpilled() == _spillSet.numSpilled(),
			"Stack too deep, but spilling is disabled because the function is part of a recursive call chain."
		);
		_spillSet = std::move(candidateSpillSets[best]);
		stackIn = std::move(proposals[best]);
	}
	return stackIn;
}
