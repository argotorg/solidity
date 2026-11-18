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

#include <libyul/backends/evm/ssa/PhiInverse.h>
#include <libyul/backends/evm/ssa/Stack.h>
#include <libyul/backends/evm/ssa/StackUtils.h>

#include <range/v3/algorithm/count.hpp>
#include <range/v3/algorithm/replace.hpp>

#include <tuple>

using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::stack;

namespace
{
void handlePhiFunctions(StackData& _stackData, PhiInverse const& _phiInverse, LivenessAnalysis::LivenessData const& _liveness, SSACFG const& _cfg)
{
	// add any phi function values here that are not already contained in the stack
	for (auto const& [phi, preImage]: _phiInverse.data())
	{
		auto reversedStackData = _stackData | ranges::views::reverse;
		auto const phiSlot = StackSlot::makeValue(_cfg, phi);
		auto const preImageSlot = StackSlot::makeValue(_cfg, preImage);
		auto it = ranges::find(reversedStackData, preImageSlot);
		if (_liveness.contains(preImage))
		{
			// Both the phi function and the preimage are part of the live-in set.
			// If the preimage occurs more than once on the stack, one occurrence is
			// symbolically replaced by the phi function; otherwise, we push the phi value.
			if (ranges::count(_stackData, preImageSlot) > 1)
				*it = phiSlot;
			else
				_stackData.emplace_back(phiSlot);
		}
		else
		{
			// replace all occurrences of the preimage with the phi value
			ranges::replace(_stackData, preImageSlot, phiSlot);
			// if it's not contained, push it (could be derived from a literal)
			if (it == ranges::end(reversedStackData))
				_stackData.emplace_back(phiSlot);
		}
	}
}

void declareJunk(Stack& _stack, LivenessAnalysis::LivenessData const& _live)
{
	for (StackOffset offset{0}; offset < _stack.size(); ++offset.value)
	{
		auto const& slot = _stack[offset];
		if (slot.isValue() && !_live.contains(slot.value()))
			_stack.declareJunk(offset);
	}
}

}

StackData stack::chooseBlockStackIn(
	SSACFG const& _cfg,
	SSACFG::BlockId const _block,
	std::vector<IncomingEdge> const& _edges,
	LivenessAnalysis::LivenessData const& _liveIn,
	spill::SpillSet& _spillSet,
	bool const _spillingAllowed
)
{
	yulAssert(!_edges.empty());
	StackData stackIn;
	if (_cfg.block(_block).entries.size() == 1)
	{
		// pass through
		yulAssert(_edges.size() == 1);
		stackIn = _edges[0].stack;
		handlePhiFunctions(stackIn, PhiInverse(_cfg, _edges[0].predecessor, _block), _liveIn, _cfg);
		Stack stack(stackIn);
		declareJunk(stack, _liveIn);
	}
	else
	{
		// Pre-compute each parent's proposal
		std::vector<StackData> proposals(_edges.size());
		for (std::size_t i = 0; i < _edges.size(); ++i)
		{
			proposals[i] = _edges[i].stack;
			handlePhiFunctions(proposals[i], PhiInverse(_cfg, _edges[i].predecessor, _block), _liveIn, _cfg);
			{
				Stack stack(proposals[i]);
				declareJunk(stack, _liveIn);
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
					stackPreImage(_cfg, proposals[i], PhiInverse(_cfg, _edges[j].predecessor, _block)),
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
