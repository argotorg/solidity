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

#include <libyul/backends/evm/ssa/spill/SpillSet.h>

#include <libyul/backends/evm/ssa/Stack.h>
#include <libyul/backends/evm/ssa/StackLayout.h>
#include <libyul/backends/evm/ssa/stack/Shuffler.h>

using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::spill;

namespace
{

/// Build the symbolic stack right after `_producer` completes by replaying the recorded shuffles
/// and operation effects from the block's `stackIn`
StackData computeOperationOut(
	SSACFG const& _cfg,
	SSACFGStackLayout const& _layout,
	InstId const _producer
)
{
	yulAssert(_cfg.isOperation(_producer), fmt::format("{} is not an operation", _producer));
	SSACFG::BlockId const block = _cfg.inst(_producer).block;
	auto const& blockLayout = _layout[block];
	yulAssert(blockLayout, fmt::format("producer {}'s block has no layout", _producer));

	StackData opOutStack = blockLayout->stackIn;
	std::size_t opIndex = 0;
	for (InstId const id: _cfg.block(block).instructions)
	{
		if (!_cfg.isOperation(id))
			continue;
		yulAssert(opIndex < blockLayout->operationShuffles.size());
		replay(opOutStack, blockLayout->operationShuffles[opIndex]);
		++opIndex;

		SSACFG::Inst const& inst = _cfg.inst(id);
		// a call that can continue also consumes its return label, which sits right below the inputs
		std::size_t consumedSlots = inst.inputs.size();
		if (inst.opcode == InstOpcode::Call && _cfg.callPayload(id).canContinue)
			++consumedSlots;
		yulAssert(opOutStack.size() >= consumedSlots, "operation input layout smaller than consumed slot count");
		opOutStack.resize(opOutStack.size() - consumedSlots);
		for (InstId const output: _cfg.outputsOf(id))
			opOutStack.push_back(StackSlot::makeValue(_cfg, output));

		if (id == _producer)
			return opOutStack;
	}
	yulAssert(false, fmt::format("producer {} not found in its block's instructions", _producer));
	solidity::util::unreachable();
}

}

void SpillSet::closeUnderReachabilityConstraints(SSACFG const& _cfg, SSACFGStackLayout const& _layout, SpillStorePlan& _storePlan)
{
	while (true)
	{
		std::vector<InstId> functionArguments;
		std::map<BlockId, std::vector<InstId>> blockPhis;
		std::map<InstId, std::vector<InstId>> operationOutputs;
		for (InstId const value: spilledValues())
			if (_cfg.isFunctionArg(value))
				functionArguments.push_back(value);
			else if (_cfg.isPhi(value))
				blockPhis[_cfg.inst(value).block].push_back(value);
			else
			{
				InstId const producer = _cfg.isProjection(value) ? _cfg.inst(value).inputs.front() : value;
				yulAssert(_cfg.isOperation(producer), fmt::format("spilled value {} has no semantic definition site", value));
				operationOutputs[producer].push_back(value);
			}

		SpillStorePlan plan;
		bool complete = true;
		if (!functionArguments.empty())
		{
			auto const& entryLayout = _layout[_cfg.entry];
			yulAssert(entryLayout, "entry block has no layout for function-argument stores");
			complete = planStoreGroup(_cfg, entryLayout->stackIn, functionArguments, plan.functionEntry);
		}

		for (auto const& [block, phis]: blockPhis)
		{
			if (!complete)
				break;
			auto const& blockLayout = _layout[block];
			yulAssert(blockLayout, fmt::format("block {} has no layout for phi stores", block));
			complete = planStoreGroup(_cfg, blockLayout->stackIn, phis, plan.blockEntries[block]);
		}

		for (auto const& [producer, outputs]: operationOutputs)
		{
			if (!complete)
				break;
			complete = planStoreGroup(
				_cfg,
				computeOperationOut(_cfg, _layout, producer),
				outputs,
				plan.operationOutputs[producer]
			);
		}

		if (!complete)
			continue;
		_storePlan = std::move(plan);
		return;
	}
}

bool SpillSet::planStoreGroup(
	SSACFG const& _cfg,
	StackData const& _defStack,
	std::vector<InstId> const& _pending,
	std::vector<SpillStorePlan::Store>& _stores)
{
	SpillSet initializedSpills = *this;
	// Values spilled at other sites are initialized whenever they can occur on this definition stack. Same-site
	// values are not initialized until their store has been planned below.
	for (InstId const value: _pending)
	{
		std::size_t const erased = initializedSpills.m_values.erase(value);
		yulAssert(erased == 1, fmt::format("pending store {} is not spilled", value));
	}

	// Plan stores from the highest pending value down. Same-site siblings above the current value have therefore
	// already been initialized, so an unreachable blocker can only require a new global spill.
	std::set<InstId> uninitializedPending(_pending.begin(), _pending.end());
	std::set<InstId> unpositionedPending = uninitializedPending;
	std::vector<InstId> pendingByHeight;
	pendingByHeight.reserve(_pending.size());
	for (auto stackIt = _defStack.rbegin(); stackIt != _defStack.rend(); ++stackIt)
		if (stackIt->isValue() && unpositionedPending.erase(stackIt->value()))
			pendingByHeight.push_back(stackIt->value());
	yulAssert(unpositionedPending.empty(), "same-site spill is absent from its definition stack");

	StackData target;
	target.reserve(_defStack.size() + 1);
	target.insert(target.end(), _defStack.begin(), _defStack.end());
	StackData workStack;
	workStack.reserve(_defStack.size() + 1);
	for (InstId const value: pendingByHeight)
	{
		StackSlot const valueSlot = StackSlot::makeValue(_cfg, value);
		target.push_back(valueSlot);
		workStack.assign(_defStack.begin(), _defStack.end());
		SpillSet planningSpills = std::move(initializedSpills);
		stack::ShuffleResult result = stack::shuffle(workStack, target, planningSpills);
		target.pop_back();
		yulAssert(
			result.status == stack::ShuffleResult::Status::Admissible,
			fmt::format("def-site store for {} is infeasible even with spill discovery", value)
		);

		bool discoveredSpill = false;
		for (InstId const blocker: planningSpills.spilledValues())
			if (!isSpilled(blocker))
			{
				add(blocker);
				discoveredSpill = true;
			}
		if (discoveredSpill)
			return false;

		for (InstId const pending: uninitializedPending)
			yulAssert(
				!planningSpills.isSpilled(pending),
				fmt::format("store for {} depends on uninitialized same-site spill {}", value, pending)
			);
		for (ShuffleOp const& op: result.trace)
			if (op.kind == ShuffleOp::Kind::Load)
				yulAssert(
					planningSpills.isSpilled(op.slot.value()),
					fmt::format("store for {} loads unavailable spill {}", value, op.slot.value())
				);

		result.trace.push_back(ShuffleOp::store(valueSlot));
		_stores.push_back(SpillStorePlan::Store{value, std::move(result.trace)});
		std::size_t const erased = uninitializedPending.erase(value);
		yulAssert(erased == 1, fmt::format("store for {} was already initialized", value));
		planningSpills.add(value);
		initializedSpills = std::move(planningSpills);
	}
	return true;
}
