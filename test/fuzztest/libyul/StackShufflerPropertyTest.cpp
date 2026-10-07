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

#include <libyul/backends/evm/ssa/InstructionStore.h>
#include <libyul/backends/evm/ssa/stack/ShuffleTrace.h>
#include <libyul/backends/evm/ssa/stack/Slot.h>
#include <libyul/backends/evm/ssa/stack/Utils.h>
#include <libyul/backends/evm/ssa/stack/spill/Set.h>
#include <libyul/backends/evm/ssa/stack/Shuffler.h>

#include <range/v3/action/sort.hpp>
#include <range/v3/action/unique.hpp>
#include <range/v3/algorithm/any_of.hpp>
#include <range/v3/algorithm/find_if.hpp>
#include <range/v3/range/conversion.hpp>
#include <range/v3/view/filter.hpp>
#include <range/v3/view/transform.hpp>

#include <fuzztest/fuzztest.h>
#include <gtest/gtest.h>

#include <algorithm>
#include <cstddef>
#include <iterator>
#include <optional>
#include <utility>
#include <vector>

using namespace solidity::yul::ssa;

namespace solidity::yul::test
{

namespace
{

constexpr std::size_t maxStackSize = 40;

/// Fixed pool of slots the fuzzed stacks are assembled from
struct SlotPool
{
	static constexpr std::size_t numValues = 8;
	static constexpr std::size_t numLiterals = 4;

	std::vector<stack::Slot> values;
	std::vector<stack::Slot> literals;

	static SlotPool const& instance()
	{
		static SlotPool const pool;
		return pool;
	}

private:
	SlotPool()
	{
		InstructionStore store;
		for (std::size_t i = 0; i < numValues; ++i)
			values.push_back(stack::Slot::makeValue(store, store.appendBuiltinCall({0}, {}, {})));
		for (std::size_t i = 0; i < numLiterals; ++i)
			literals.push_back(stack::Slot::makeValue(store, store.appendLiteral({0}, u256(i)).first));
	}
};

enum class ReturnLabel { Excluded, Included };

/// Domain of a single source stack slot: a value, a literal, a call return label, or junk
fuzztest::Domain<stack::Slot> sourceSlotDomain(ReturnLabel const _returnLabel)
{
	SlotPool const& pool = SlotPool::instance();
	std::vector<stack::Slot> elements = pool.values;
	elements.insert(elements.end(), pool.literals.begin(), pool.literals.end());
	elements.push_back(stack::Slot::makeFunctionCallReturnLabel(0));
	elements.push_back(stack::Slot::makeJunk());
	if (_returnLabel == ReturnLabel::Included)
		elements.push_back(stack::Slot::makeFunctionReturnLabel(0));
	return fuzztest::ElementOf(std::move(elements));
}

/// Domain of the pre-spilled values, drawn from the value part of the slot pool independently of
/// the source stack: spilled values are reloadable from memory, so they may well not be on the
/// stack at all while still being producible in a target. Duplicate draws collapse in `toSpillSet`
fuzztest::Domain<std::vector<stack::Slot>> spilledSlotsDomain()
{
	return fuzztest::VectorOf(fuzztest::ElementOf(SlotPool::instance().values))
		.WithMaxSize(SlotPool::numValues);
}

stack::spill::Set toSpillSet(std::vector<stack::Slot> const& _slots)
{
	stack::spill::Set spills;
	for (stack::Slot const& slot: _slots)
		if (!spills.isSpilled(slot))
			spills.add(slot);
	return spills;
}

/// A shuffle input
struct ShuffleCase
{
	stack::Data source;
	stack::Data target;
	std::vector<stack::Slot> spilled;
};

/// Domain of a single target stack slot, given the already-generated source stack and the
/// pre-spilled values
fuzztest::Domain<stack::Slot> targetSlotDomain(
	stack::Data const& _source,
	std::vector<stack::Slot> const& _spilled
)
{
	SlotPool const& pool = SlotPool::instance();
	std::vector<stack::Slot> elements =
		_source |
		ranges::views::filter(
			[](stack::Slot const& _slot) { return _slot.isValue() && !_slot.isLiteralValue(); }
		) |
		ranges::to<std::vector>;
	elements.insert(elements.end(), _spilled.begin(), _spilled.end());
	elements |= ranges::actions::sort | ranges::actions::unique;
	elements.insert(elements.end(), pool.literals.begin(), pool.literals.end());
	elements.push_back(stack::Slot::makeFunctionCallReturnLabel(0));
	elements.push_back(stack::Slot::makeFunctionCallReturnLabel(1));
	elements.push_back(stack::Slot::makeJunk());
	return fuzztest::ElementOf(std::move(elements));
}

fuzztest::Domain<ShuffleCase> freeDrawDomain()
{
	return fuzztest::FlatMap(
		[](stack::Data const& _source, std::vector<stack::Slot> const& _spilled) {
			return fuzztest::StructOf<ShuffleCase>(
				fuzztest::Just(_source),
				fuzztest::VectorOf(targetSlotDomain(_source, _spilled)).WithMaxSize(maxStackSize),
				fuzztest::Just(_spilled)
			);
		},
		fuzztest::VectorOf(sourceSlotDomain(ReturnLabel::Excluded)).WithMaxSize(maxStackSize),
		spilledSlotsDomain()
	);
}

/// Replaces all but the first function return label by junk
stack::Data keepAtMostOneReturnLabel(stack::Data _stack)
{
	auto const isReturnLabel = [](stack::Slot const& _slot) { return _slot.isFunctionReturnLabel(); };
	if (auto const first = ranges::find_if(_stack, isReturnLabel); first != _stack.end())
		std::replace_if(std::next(first), _stack.end(), isReturnLabel, stack::Slot::makeJunk());
	return _stack;
}

fuzztest::Domain<std::vector<bool>> junkMaskDomain(std::size_t const _size)
{
	return fuzztest::VectorOf(fuzztest::ElementOf<bool>({false, false, false, true})).WithSize(_size);
}

/// Applies `_permutation` to `_source`, followed by declaring the junk positions
stack::Data permutedTarget(
	stack::Data const& _source,
	std::vector<std::size_t> const& _permutation,
	std::vector<bool> const& _junkMask
)
{
	yulAssert(_permutation.size() == _source.size() && _junkMask.size() == _source.size());
	stack::Data target =
		_permutation |
		ranges::views::transform([&](std::size_t const _offset) { return _source[_offset]; }) |
		ranges::to<std::vector>;
	for (std::size_t i = 0; i < target.size(); ++i)
		if (_junkMask[i] && !target[i].isFunctionReturnLabel())
			target[i] = stack::Slot::makeJunk();
	return target;
}

fuzztest::Domain<ShuffleCase> permutedDomain()
{
	return fuzztest::FlatMap(
		[](stack::Data const& _sourceDraw, std::vector<stack::Slot> const& _spilled) {
			stack::Data const source = keepAtMostOneReturnLabel(_sourceDraw);
			return fuzztest::StructOf<ShuffleCase>(
				fuzztest::Just(source),
				fuzztest::Map(
					[source](std::vector<std::size_t> const& _permutation, std::vector<bool> const& _junkMask) {
						return permutedTarget(source, _permutation, _junkMask);
					},
					fuzztest::UniqueElementsVectorOf(
						fuzztest::InRange<std::size_t>(0, std::max<std::size_t>(source.size(), 1) - 1)
					).WithSize(source.size()),
					junkMaskDomain(source.size())
				),
				fuzztest::Just(_spilled)
			);
		},
		fuzztest::VectorOf(sourceSlotDomain(ReturnLabel::Included)).WithMaxSize(maxStackSize),
		spilledSlotsDomain()
	);
}

void checkShuffleProperties(
	ShuffleCase const& _case,
	bool const _spillingAllowed,
	std::size_t const _reachableDepth
)
{
	auto const& [initial, target, spilled] = _case;
	stack::spill::Set spills = toSpillSet(spilled);
	std::size_t const spilledBefore = spills.numSpilled();
	stack::Data shuffled = initial;
	stack::ShuffleResult const result = stack::shuffle(shuffled, target, spills, _spillingAllowed, _reachableDepth);

	bool const hasReturnLabel = ranges::any_of(initial, [](stack::Slot const& _s) { return _s.isFunctionReturnLabel(); });
	if (_spillingAllowed && !hasReturnLabel)
		ASSERT_EQ(result.status, stack::ShuffleResult::Status::Admissible)
			<< "source: " << stack::toString(initial) << " target: " << stack::toString(target);
	if (result.status != stack::ShuffleResult::Status::Admissible)
		return;

	if (!_spillingAllowed)
		ASSERT_EQ(spills.numSpilled(), spilledBefore) << "admissible plan added spills although spilling was disallowed";

	for (stack::ShuffleOp const& op: result.trace)
		if (op.kind == stack::ShuffleOp::Kind::Swap || op.kind == stack::ShuffleOp::Kind::Dup)
			ASSERT_LE(op.depth, _reachableDepth);

	stack::Data replayed = initial;
	replay(replayed, result.trace);
	ASSERT_TRUE(replayed == shuffled) << "replayed: " << stack::toString(replayed) << " shuffled: " << stack::toString(shuffled);

	stack::ValidationResult const validation = stack::checkLayoutCompatibility(replayed, target);
	ASSERT_TRUE(validation.ok()) << validation.formatErrors();

	// every non-generated target offset is mapped to by an initial source offset holding the demanded slot (wildcards accept anything)
	ASSERT_EQ(result.sourceOf.size(), target.size());
	for (std::size_t targetOffset = 0; targetOffset < target.size(); ++targetOffset)
		if (std::optional<stack::Offset> const sourceOffset = result.sourceOf[targetOffset])
		{
			ASSERT_LT(sourceOffset->value, initial.size());
			if (!target[targetOffset].isJunk())
				ASSERT_TRUE(initial[sourceOffset->value] == target[targetOffset])
					<< "plan serves " << stack::toString(target[targetOffset])
					<< " from " << stack::toString(initial[sourceOffset->value]);
		}
}

}

void ShuffleRealizesFreeDrawTarget(
	ShuffleCase const& _case,
	bool const _spillingAllowed,
	std::size_t const _reachableDepth
)
{
	checkShuffleProperties(_case, _spillingAllowed, _reachableDepth);
}

FUZZ_TEST(StackShufflerProperty, ShuffleRealizesFreeDrawTarget)
	.WithDomains(
		freeDrawDomain(),
		fuzztest::Arbitrary<bool>(),
		fuzztest::InRange<std::size_t>(2, reachableStackDepth)
	);

void ShuffleRealizesPermutedTarget(
	ShuffleCase const& _case,
	bool const _spillingAllowed,
	std::size_t const _reachableDepth
)
{
	checkShuffleProperties(_case, _spillingAllowed, _reachableDepth);
}

FUZZ_TEST(StackShufflerProperty, ShuffleRealizesPermutedTarget)
	.WithDomains(
		permutedDomain(),
		fuzztest::Arbitrary<bool>(),
		fuzztest::InRange<std::size_t>(2, reachableStackDepth)
	);

}
