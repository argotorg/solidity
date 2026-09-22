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

#include <libyul/backends/evm/ssa/stack/Shuffler.h>

#include <libyul/backends/evm/ssa/StackLayout.h>

#include <range/v3/algorithm/contains.hpp>
#include <range/v3/view/zip.hpp>

#include <deque>

using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::spill;

namespace
{

/// Build the symbolic stack right after `_inst` (an operation, phi, upsilon or identity) by replaying the
/// recorded shuffles and operation effects from the block's `stackIn`
StackData computeStackAfter(
	SSACFG const& _cfg,
	SSACFGStackLayout const& _layout,
	InstId const _instId
)
{
	SSACFG::BlockId const block = _cfg.inst(_instId).block;
	auto const& blockLayout = _layout[block];
	yulAssert(blockLayout, fmt::format("{}'s block has no layout", _instId));

	auto const& instructions = _cfg.block(block).instructions;
	yulAssert(blockLayout->operationShuffles.size() == instructions.size());
	StackData stack = blockLayout->stackIn;
	for (auto const& [id, shuffle]: ranges::views::zip(instructions, blockLayout->operationShuffles))
	{
		replay(stack, shuffle);

		if (
			SSACFG::Inst const& inst = _cfg.inst(id);
			inst.isOperation()
		)
		{
			// a call that can continue also consumes its return label, which sits right below the inputs
			std::size_t consumedSlots = inst.inputs.size();
			if (inst.opcode == InstOpcode::Call && _cfg.callPayload(id).canContinue)
				++consumedSlots;
			yulAssert(stack.size() >= consumedSlots, "operation input layout smaller than consumed slot count");
			for (std::size_t i = 0; i < consumedSlots; ++i)
				stack.pop_back();
			_cfg.forEachOutput(id, [&](InstId const output) {
				stack.push_back(StackSlot::makeValue(_cfg, output));
			});
		}

		if (id == _instId)
			return stack;
	}
	yulAssert(false, fmt::format("{} not found in its block's instructions", _instId));
	solidity::util::unreachable();
}

/// The symbolic stack the Emitter faces at `_value`'s definition, where its `mstore` fires. Two cases:
/// - a function argument: it has no producer operation and lives on the function entry stack, where CodeTransform emits `mstore` while the args are still laid out;
/// - any other value: it sits on the stack after its producer
StackData defStackFor(
	SSACFG const& _cfg,
	SSACFGStackLayout const& _layout,
	InstId const _value
)
{
	if (_cfg.isFunctionArg(_value))
	{
		auto const& entryLayout = _layout[_cfg.entry];
		yulAssert(entryLayout, "entry block has no layout for function-arg def-site");
		return entryLayout->stackIn;
	}
	InstId const producer = _cfg.isProjection(_value) ? _cfg.inst(_value).inputs.front() : _value;
	return computeStackAfter(_cfg, _layout, producer);
}

}

void SpillSet::closeUnderReachabilityConstraints(SSACFG const& _cfg, SSACFGStackLayout const& _layout, SpillStoreTraces* _storeTraces)
{
	if (_storeTraces)
		_storeTraces->clear();

	// work queue over variables that are marked for spillage
	std::deque<SpillKey> queue;
	for (SpillKey const key: spilledValues())
		queue.push_back(key);

	while (!queue.empty())
	{
		SpillKey const key = queue.front();
		queue.pop_front();

		if (key.isShadow())
		{
			// a shadow is defined at each upsilon of its phi; a dead write (the layout left no shadow on the
			// stack) needs no store
			for (SSACFG::BlockId const blockId: _cfg.liveBlocks())
				_cfg.forEachUpsilon(_cfg.block(blockId), [&](InstId const upsilonId, SSACFG::Inst const&) {
					if (_cfg.upsilonPhi(upsilonId) != key.shadowPhi())
						return;
					StackData const defStack = computeStackAfter(_cfg, _layout, upsilonId);
					if (ranges::contains(defStack, key))
						ensureDefSiteFeasible(key, upsilonId, defStack, queue, _storeTraces);
				});
		}
		else
		{
			InstId const value = key.value();
			StackData const defStack = defStackFor(_cfg, _layout, value);
			ensureDefSiteFeasible(key, value, defStack, queue, _storeTraces);
		}
	}
}

void SpillSet::ensureDefSiteFeasible(
	SpillKey const _key,
	InstId const _defSite,
	StackData const& _defStack,
	std::deque<SpillKey>& _workQueue,
	SpillStoreTraces* _storeTraces)
{
	// predicate = spill set minus the owner; the shuffle accumulates discovered culprits here.
	SpillSet spillSetWithoutOwner = without(_key);
	// [... defStack ..., _key]
	StackData const target = [&]{
		StackData result;
		result.reserve(_defStack.size() + 1);
		result.insert(result.end(), _defStack.begin(), _defStack.end());
		result.push_back(_key);
		return result;
	}();
	StackData workStack = _defStack;
	stack::ShuffleResult result = stack::shuffle(workStack, target, spillSetWithoutOwner);
	yulAssert(
		result.status == stack::ShuffleResult::Status::Admissible,
		fmt::format("def-site store for {} infeasible even after spilling siblings (status={})", _key, static_cast<int>(result.status))
	);

	// - if `_key` is reachable, it can be just DUPed and there shouldn't have been a stack too deep with it
	// - if `_key` is unreachable, there are > reachable stack depth distinct slots strictly above it and the
	//   shuffler heuristics should not pick anything that is already too deep as culprit
	yulAssert(!spillSetWithoutOwner.isSpilled(_key), "spill-aware shuffle reported the owner as its own blocker");

	if (_storeTraces)
	{
		// the `mstore` consuming the variable from the top concludes the def-site trace
		result.trace.push_back(ShuffleOp::store(_key));
		(*_storeTraces)[_defSite] = std::move(result.trace);
	}

	for (SpillKey const culprit: spillSetWithoutOwner.spilledValues())
	{
		if (isSpilled(culprit))
			continue;
		add(culprit);
		_workQueue.push_back(culprit);
	}
}

SpillSet SpillSet::without(SpillKey const _key) const
{
	SpillSet result = *this;
	result.m_values.erase(_key);
	return result;
}
