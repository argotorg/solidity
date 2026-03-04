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

#include <libyul/backends/evm/ssa/StackLayoutGenerator.h>

#include <libyul/backends/evm/ssa/JunkAdmittingBlocksFinder.h>
#include <libyul/backends/evm/ssa/PhiInverse.h>
#include <libyul/backends/evm/ssa/StackShuffler.h>
#include <libyul/backends/evm/ssa/StackUtils.h>

#include <range/v3/algorithm/count.hpp>
#include <range/v3/algorithm/min_element.hpp>
#include <range/v3/algorithm/replace.hpp>
#include <range/v3/to_container.hpp>

#include <boost/container/flat_map.hpp>
#include <queue>

using namespace solidity::yul::ssa;

namespace
{
void handlePhiFunctions(StackData& _stackData, PhiInverse const& _phiInverse, LivenessAnalysis::LivenessData const& _liveness)
{
	// add any phi function values here that are not already contained in the stack
	for (auto const& [phi, preImage]: _phiInverse.data())
	{
		auto reversedStackData = _stackData | ranges::views::reverse;
		auto it = ranges::find(reversedStackData, StackSlot::makeValueID(preImage));
		if (_liveness.contains(preImage))
		{
			// Both the phi function and the preimage are part of the live-in set.
			// If the preimage occurs more than once on the stack, one occurrence is
			// symbolically replaced by the phi function; otherwise, we push the phi value.
			if (ranges::count(_stackData, StackSlot::makeValueID(preImage)) > 1)
				*it = StackSlot::makeValueID(phi);
			else
				_stackData.emplace_back(StackSlot::makeValueID(phi));
		}
		else
		{
			// replace all occurrences of the preimage with the phi value
			ranges::replace(_stackData, StackSlot::makeValueID(preImage), StackSlot::makeValueID(phi));
			// if it's not contained, push it (could be derived from a literal)
			if (it == ranges::end(reversedStackData))
				_stackData.emplace_back(StackSlot::makeValueID(phi));
		}
	}
}

using StackType = Stack<CountingInstructionsCallbacks>;

void declareJunk(StackType& _stack, LivenessAnalysis::LivenessData const& _live)
{
	for (StackOffset offset{0}; offset < _stack.size(); ++offset.value)
	{
		auto const& slot = _stack[offset];
		if (slot.isValueID() && !_live.contains(slot.valueID()))
			_stack.declareJunk(offset);
	}
}

}

SSACFGStackLayout StackLayoutGenerator::generate(LivenessAnalysis const& _liveness, CallSites const& _callSites)
{
	return StackLayoutGenerator(_liveness, _callSites).m_resultLayout;
}

StackLayoutGenerator::StackLayoutGenerator(LivenessAnalysis const& _liveness, CallSites const& _callSites):
	m_cfg(_liveness.cfg()),
	m_liveness(_liveness),
	m_callSites(_callSites),
	m_junkAdmittingBlocksFinder(std::make_unique<JunkAdmittingBlocksFinder>(_liveness.cfg(), _liveness.topologicalSort())),
	m_resultLayout(m_cfg.numBlocks())
{
	// traverse the cfg layer-wise using Kahn's algorithm:
	// if a block is visited, the predecessors of that block have already their exit layouts defined
	// with minor exceptions when dealing with back-edges
	{
		// Future optimization: it might be beneficial to revisit the loop heads (back edge targets) after the first iteration
		std::vector<std::size_t> inDegreesIgnoringBackedges(m_cfg.numBlocks(), 0);

		for (SSACFG::BlockId id{0}; id.value < m_cfg.numBlocks(); ++id.value)
			for (auto const& entry: m_cfg.block(id).entries)
				if (!m_liveness.topologicalSort().backEdge(entry, id))
					inDegreesIgnoringBackedges[id.value] += 1;

		std::queue<SSACFG::BlockId> traversalQueue;
		traversalQueue.push(m_cfg.entry);

		std::size_t numVisited = 0;
		while (!traversalQueue.empty())
		{
			auto currentBlockId = traversalQueue.front();
			traversalQueue.pop();

			visitBlock(currentBlockId);

			m_cfg.block(currentBlockId).forEachExit([&](SSACFG::BlockId const& _exit){
				if (--inDegreesIgnoringBackedges[_exit.value] == 0)
					traversalQueue.push(_exit);
			});
			++numVisited;
		}
		yulAssert(numVisited == m_liveness.topologicalSort().preOrder().size());
	}
}

void StackLayoutGenerator::defineStackIn(SSACFG::BlockId const& _blockId)
{
	// we already have an input layout defined, return
	if (m_resultLayout[_blockId])
		return;
	BlockLayout blockLayout{};

	if (_blockId == m_cfg.entry)
	{
		if (m_cfg.function)
			blockLayout.stackIn =
				m_cfg.arguments |
				ranges::views::reverse |
				ranges::views::transform([](auto&& _variableAndValueId) -> Slot { return Slot::makeValueID(std::get<1>(_variableAndValueId)); }) |
				ranges::to<std::vector>;
		m_resultLayout[_blockId] = blockLayout;
		return;
	}

	auto const& block = m_cfg.block(_blockId);

	std::vector<std::pair<SSACFG::BlockId, StackData const*>> parentExits;
	for (auto const& entry: block.entries)
		if (m_resultLayout[entry])
			parentExits.emplace_back(entry, &m_resultLayout[entry]->stackOut);

	yulAssert(!parentExits.empty(), fmt::format("None of the parents of block {} were generated", _blockId));

	if (block.entries.size() == 1)
	{
		// pass through
		yulAssert(parentExits.size() == 1);
		blockLayout.stackIn = *parentExits[0].second;

		if (!block.phis.empty())
			handlePhiFunctions(blockLayout.stackIn, PhiInverse(m_cfg, parentExits[0].first, _blockId), m_liveness.liveIn(_blockId));
	}
	else
	{
		// we have more than one entry and need to unify or at the very least apply phi fct.
		auto const& liveIn = m_liveness.liveIn(_blockId);
		std::vector cumulativeCosts(parentExits.size(), std::numeric_limits<std::size_t>::max());
		for (std::size_t i = 0; i < parentExits.size(); ++i)
		{
			if (!parentExits[i].second)
				continue;
			std::size_t cumulativeCost = 0;
			auto referenceStackIn = *parentExits[i].second;
			{
				StackType stack(referenceStackIn, {});
				declareJunk(stack, liveIn);
			}
			handlePhiFunctions(referenceStackIn, PhiInverse(m_cfg, parentExits[i].first, _blockId), liveIn);
			for (std::size_t j = 0; j < parentExits.size(); ++j)
			{
				if (j != i)
				{
					if (parentExits[j].second != nullptr)
					{
						auto otherStackIn = *parentExits[j].second;
						StackType stack(otherStackIn, {});
						StackShuffler<StackType::Callbacks>::shuffle(
							stack,
							stackPreImage(referenceStackIn, PhiInverse(m_cfg, parentExits[j].first, _blockId)),
							{},
							referenceStackIn.size()
						);
						cumulativeCost += stack.callbacks().numOps;
					}
				}
			}
			cumulativeCosts[i] = cumulativeCost;
		}
		auto const argMin = static_cast<std::size_t>(
			std::distance(cumulativeCosts.begin(), ranges::min_element(cumulativeCosts))
		);
		yulAssert(parentExits[argMin].second);
		blockLayout.stackIn = *parentExits[argMin].second;
		StackType stack(blockLayout.stackIn, {});
		declareJunk(stack, liveIn);
		handlePhiFunctions(blockLayout.stackIn, PhiInverse(m_cfg, parentExits[argMin].first, _blockId), liveIn);
	}
	m_resultLayout[_blockId] = blockLayout;
}

void StackLayoutGenerator::visitBlock(SSACFG::BlockId const& _blockId)
{
	defineStackIn(_blockId);
	yulAssert(m_resultLayout[_blockId]);
	BlockLayout& blockLayout = *m_resultLayout[_blockId];

	SSACFG::BasicBlock const& block = m_cfg.block(_blockId);

	StackData currentStackData = blockLayout.stackIn;
	StackType stack(currentStackData, {});
	bool const junkCanBeAdded = m_junkAdmittingBlocksFinder->allowsAdditionOfJunk(_blockId);

	auto const& operationsLiveOut = m_liveness.operationsLiveOut(_blockId);
	blockLayout.operationIn.reserve(block.operations.size());
	for (std::size_t operationIndex = 0; operationIndex < block.operations.size(); ++operationIndex)
	{
		SSACFG::Operation const& operation = block.operations[operationIndex];
		LivenessAnalysis::LivenessData opLiveOut = operationsLiveOut[operationIndex];
		auto opLiveOutWithoutOutputs = opLiveOut;
		for (auto const& output: operation.outputs)
			opLiveOutWithoutOutputs.erase(output);

		std::vector<Slot> requiredStackTop;
		if (auto const* call = std::get_if<SSACFG::Call>(&operation.kind))
			if (call->canContinue)
			{
				auto const callSiteID = m_callSites.callSiteID(&call->call.get());
				yulAssert(callSiteID.has_value());
				requiredStackTop.emplace_back(Slot::makeFunctionCallReturnLabel(*callSiteID));
			}
		requiredStackTop += operation.inputs | ranges::views::transform(Slot::makeValueID);

		for (StackType::Depth depth{0}; depth < stack.size(); ++depth.value)
			if (
				stack.slot(depth).isValueID() &&
				!opLiveOutWithoutOutputs.contains(stack.slot(depth).valueID()) &&
				ranges::find(requiredStackTop, stack.slot(depth)) == ranges::end(requiredStackTop)
			)
				stack.declareJunk(depth);

		std::size_t const targetSize = findOptimalTargetSize(stack.data(), requiredStackTop, opLiveOutWithoutOutputs, junkCanBeAdded);
		StackShuffler<StackType::Callbacks>::shuffle(
			stack,
			requiredStackTop,
			opLiveOutWithoutOutputs,
			targetSize
		);

		blockLayout.operationIn.push_back(currentStackData);
		for (std::size_t i = 0; i < requiredStackTop.size(); ++i)
			stack.pop();
		for (auto const& val: operation.outputs)
			stack.push(Slot::makeValueID(val));
	}

	if (auto const* cjump = std::get_if<SSACFG::BasicBlock::ConditionalJump>(&block.exit))
	{
		auto const& zeroLiveIn = m_liveness.liveIn(cjump->zero);
		auto const& blockLiveOut = m_liveness.liveOut(_blockId);

		// check if we have to do anything (dup the condition, bring it to the top etc)
		bool const conditionSlotAlreadyFinal =
			!blockLiveOut.contains(cjump->condition) &&  // if our live out does not contain the condition (ie we dont have to dup it)
			!stack.empty() &&   // our stack is not empty
			stack.top().isValueID() && stack.top().valueID() == cjump->condition;  // and the condition is already on top
		if (!conditionSlotAlreadyFinal)
		{
			auto const condition = Slot::makeValueID(cjump->condition);
			auto const targetSize = findOptimalTargetSize(stack.data(), {condition}, blockLiveOut, false);
			StackShuffler<StackType::Callbacks>::shuffle(
				stack, {condition}, blockLiveOut, targetSize
			);
		}

		yulAssert(!stack.empty() && stack.top().isValueID() && stack.top().valueID() == cjump->condition);
		yulAssert(m_cfg.block(cjump->nonZero).phis.empty());

		// define zero and non-zero stack in layouts
		{
			std::optional<BlockLayout>& nonZeroLayout = m_resultLayout[cjump->nonZero];
			yulAssert(!nonZeroLayout, "There should be no way to reach this block other than by going through the parent.");
			nonZeroLayout = BlockLayout{};
			nonZeroLayout->stackIn = currentStackData;
			// Remove condition; consumed by JUMPI
			nonZeroLayout->stackIn.pop_back();

			if (
				std::optional<BlockLayout>& zeroLayout = m_resultLayout[cjump->zero];
				!zeroLayout
			)
			{
				// same as nonzero stack in initially
				zeroLayout = nonZeroLayout;
				handlePhiFunctions(zeroLayout->stackIn, PhiInverse(m_cfg, _blockId, cjump->zero), zeroLiveIn);
				StackType zeroStack(zeroLayout->stackIn, {});
				declareJunk(zeroStack, zeroLiveIn);
			}
		}
	}

	blockLayout.stackOut = currentStackData;
}
