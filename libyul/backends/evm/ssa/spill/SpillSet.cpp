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

#include <libyul/backends/evm/ssa/Stack.h>
#include <libyul/backends/evm/ssa/StackLayout.h>
#include <libyul/backends/evm/ssa/StackUtils.h>

#include <range/v3/algorithm/contains.hpp>
#include <range/v3/view/zip.hpp>

#include <deque>

using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::spill;

namespace
{

/// Build the symbolic stack right after the Inst `_producer` completes by replaying the recorded shuffles
/// and operation effects from the block's `stackIn`
StackData computeOperationOut(
	SSACFG const& _cfg,
	SSACFGStackLayout const& _layout,
	InstId const _producer
)
{
	SSACFG::BlockId const block = _cfg.inst(_producer).block;
	auto const& blockLayout = _layout[block];
	yulAssert(blockLayout, fmt::format("producer {}'s block has no layout", _producer));

	auto const& instructions = _cfg.block(block).instructions;
	yulAssert(blockLayout->operationShuffles.size() == instructions.size());
	StackData opOutStack = blockLayout->stackIn;
	for (auto const& [id, shuffle]: ranges::views::zip(instructions, blockLayout->operationShuffles))
	{
		replay(opOutStack, shuffle);
		if (_cfg.isOperation(id))
			applyOperation(_cfg, id, opOutStack);

		if (id == _producer)
			return opOutStack;
	}
	yulAssert(false, fmt::format("producer {} not found in its block's instructions", _producer));
	solidity::util::unreachable();
}

/// The Inst behind which the value `_value` is stored.
/// For projections right behind their operation.
InstId storeSiteOf(SSACFG const& _cfg, InstId const _value)
{
	return _cfg.isProjection(_value) ? _cfg.inst(_value).inputs.front() : _value;
}

struct DefSite
{
	SpillStoreSite site;
	/// the slot stored at the site, the variable itself or, for a phi that shares its key, its shadow slot
	StackSlot slot;
	/// the symbolic stack at the site
	StackData stack;
};

/// The sites at which the spilled variable `_key` is stored (see `SpillStoreSite`)
std::vector<DefSite> defSitesFor(
	SSACFG const& _cfg,
	SSACFGStackLayout const& _layout,
	SpillSet const& _spillSet,
	SpillKey const _key
)
{
	bool const isPhiSharingItsKey =
		_key.isPhiValue() && _spillSet.keyOf(StackSlot::makeShadow(_cfg, _key.value())) == _key;
	if (_key.isValue() && !isPhiSharingItsKey)
	{
		InstId const site = storeSiteOf(_cfg, _key.value());
		return {{.site = site, .slot = _key, .stack = computeOperationOut(_cfg, _layout, site)}};
	}

	StackSlot const shadowSlot = _key.isShadow() ? _key : StackSlot::makeShadow(_cfg, _key.value());
	std::vector<DefSite> sites;
	for (SSACFG::BlockId const blockId: _cfg.liveBlocks())
		if (_layout[blockId])
			_cfg.forEachUpsilon(_cfg.block(blockId), [&](InstId const _upsilon, SSACFG::Inst const&) {
				if (_cfg.upsilonPhi(_upsilon) != shadowSlot.shadowPhi())
					return;
				// a shadow slot that got spilled while its copy was left to an edge is not on the stack here
				StackData stack = computeOperationOut(_cfg, _layout, _upsilon);
				if (ranges::contains(stack, shadowSlot))
					sites.push_back({.site = _upsilon, .slot = shadowSlot, .stack = std::move(stack)});
			});
	return sites;
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

		for (auto const& [site, slot, defStack]: defSitesFor(_cfg, _layout, *this, key))
			ensureDefSiteFeasible(slot, site, defStack, queue, _storeTraces);
	}
}

void SpillSet::ensureDefSiteFeasible(
	StackSlot const _slot,
	SpillStoreSite const _site,
	StackData const& _defStack,
	std::deque<SpillKey>& _workQueue,
	SpillStoreTraces* _storeTraces)
{
	// predicate = spill set minus the owner; the shuffle accumulates discovered culprits here.
	SpillSet spillSetWithoutOwner = without(_slot);
	// [... defStack ..., _slot]
	StackData const target = [&]{
		StackData result;
		result.reserve(_defStack.size() + 1);
		result.insert(result.end(), _defStack.begin(), _defStack.end());
		result.push_back(_slot);
		return result;
	}();
	StackData workStack = _defStack;
	stack::ShuffleResult result = stack::shuffle(workStack, target, spillSetWithoutOwner);
	yulAssert(
		result.status == stack::ShuffleResult::Status::Admissible,
		fmt::format("def-site store for {} infeasible even after spilling siblings (status={})", _slot, static_cast<int>(result.status))
	);

	// - if `_slot` is reachable, it can be just DUPed and there shouldn't have been a stack too deep with it
	// - if `_slot` is unreachable, there are > reachable stack depth distinct slots strictly above it and the
	//   shuffler heuristics should not pick anything that is already too deep as culprit
	yulAssert(!spillSetWithoutOwner.isSpilled(_slot), "spill-aware shuffle reported the owner as its own blocker");

	if (_storeTraces)
	{
		// the `mstore` consuming the variable from the top concludes the def-site trace
		result.trace.push_back(ShuffleOp::store(_slot));
		(*_storeTraces)[_site][_slot] = std::move(result.trace);
	}

	for (SpillKey const culprit: spillSetWithoutOwner.spilledValues())
	{
		if (isSpilled(culprit))
			continue;
		add(culprit);
		_workQueue.push_back(culprit);
	}
}

SpillSet SpillSet::without(StackSlot const _slot) const
{
	SpillSet result = *this;
	result.m_values.erase(keyOf(_slot));
	return result;
}
