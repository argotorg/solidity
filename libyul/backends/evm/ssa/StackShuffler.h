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

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>
#include <libyul/backends/evm/ssa/Stack.h>

#include <boost/container/flat_map.hpp>

#include <range/v3/view/iota.hpp>

#include <cstddef>
#include <optional>

namespace solidity::yul::ssa
{

namespace detail
{
/// Contains information about the shuffling target, aggregates over args and live out to
/// provide a lower bound for the slot distribution.
struct Target
{
	Target(StackData const& _args, LivenessAnalysis::LivenessData const& _liveOut, std::size_t _targetSize);

	StackData const& args;
	LivenessAnalysis::LivenessData const& liveOut;
	std::size_t const size;
	std::size_t const tailSize;
	boost::container::flat_map<StackSlot, size_t> minCount;
};
/// Current state of the stack vs the shuffling target.
class State
{
public:
	State(StackData const& _stackData, Target const& _target, std::size_t _reachableStackDepth);

	std::size_t size() const;
	/// How many of `_slot` do we have on stack
	std::size_t count(StackSlot const& _slot) const;
	/// How many of `_slot` do we have in the args section of the stack
	std::size_t countInArgs(StackSlot const& _slot) const;
	/// How many of `_slot` do we have in the tail section of the stack
	std::size_t countInTail(StackSlot const& _slot) const;
	/// How many of `_slot` are (dup) reachable on stack
	std::size_t countReachable(StackSlot const& _slot) const;

	/// Obtain the amount of the provided slot that is required for distribution correctness
	std::size_t targetMinCount(StackSlot const& _slot) const;
	/// Obtain the amount of the provided slot that is required in target args
	std::size_t targetArgsCount(StackSlot const& _slot) const;

	/// Checks if the state is compatible with the target
	bool admissible() const;

	/// Checks if a particular slot is required in the target args
	bool requiredInArgs(StackSlot const& _slot) const;
	/// Checks if a particular slot is required in the target tail
	bool requiredInTail(StackSlot const& _slot) const;

	/// Checks if an offset is in the target args (bounded from below by tail size, from above by target size)
	bool offsetInTargetArgsRegion(StackOffset _offset) const;
	/// Retrieves the required argument slot for a specific stack offset
	StackSlot const& targetArg(StackOffset _targetOffset) const;
	/// Checks the current stack offset is args-compatible with a target stack offset, meaning the target offset is
	/// in the target args region and either a wildcard slot (JUNK) or a precise match for the slot at `_sourceOffset`
	bool isArgsCompatible(StackOffset _sourceOffset, StackOffset _targetOffset) const;
	/// Checks if the slot at `_targetOffset` admits any slot
	bool targetArbitrary(StackOffset _targetOffset) const;
	/// Yields whether two slots on the current stack are same, respecting stack size limits
	bool isSourceCompatible(StackOffset _sourceOffset1, StackOffset _sourceOffset2) const;
	/// Shuffling target information
	Target const& target() const;

	/// A range of offsets `[argsBegin, argsEnd)` intersected with the current stack size
	auto stackArgsRange() const
	{
		return ranges::views::iota(std::min(m_target.tailSize, m_stackData.size()), std::min(m_target.size, m_stackData.size())) | ranges::views::transform([](auto _i) { return StackOffset{_i}; });
	}

	/// A range of offsets `[0, argsBegin)` intersected with the current stack size
	auto stackTailRange() const
	{
		return ranges::views::iota(0u, std::min(m_target.tailSize, m_stackData.size())) | ranges::views::transform([](auto _i) { return StackOffset{_i}; });
	}

	/// A range of offsets `[0, stackSize)`
	auto stackRange() const
	{
		return ranges::views::iota(0u, m_stackData.size()) | ranges::views::transform([&](auto _i) { return StackOffset{_i}; });
	}

	/// A reversed range of offsets `[stackSize - reachableStackDepth - 1, stackSize)`
	auto stackSwapReachableRange() const
	{
		return ranges::views::iota(0u, std::min(m_stackData.size(), m_reachableStackDepth + 1)) | ranges::views::transform([&](auto _i) { return StackOffset{m_stackData.size() - _i - 1}; });
	}

	/// A reversed range of offsets `[stackSize - reachableStackDepth - 1, stackSize)`
	auto stackDupReachableRange() const
	{
		return ranges::views::iota(0u, std::min(m_stackData.size(), m_reachableStackDepth)) | ranges::views::transform([&](auto _i) { return StackOffset{m_stackData.size() - _i - 1}; });
	}

private:
	StackData const& m_stackData;
	Target const& m_target;
	std::size_t const m_reachableStackDepth;
	boost::container::flat_map<StackSlot, size_t> m_histogramTail;
	boost::container::flat_map<StackSlot, size_t> m_histogramArgs;
	boost::container::flat_map<StackSlot, size_t> m_histogramReachable;
	boost::container::flat_map<StackSlot, size_t> m_histogram;
};
}

template<StackManipulationCallbackConcept Callback, std::size_t ReachableStackDepth=16>
class StackShuffler
{
	using Slot = StackSlot;

public:
	static void shuffle(
		Stack<Callback>& _stack,
		StackData const& _args,
		LivenessAnalysis::LivenessData const& _liveOut,
		std::size_t _targetStackSize
	)
	{
		detail::Target const target(_args, _liveOut, _targetStackSize);
		yulAssert(_liveOut.size() <= target.size, "not enough tail space");
		{
			// check that all required values are on stack
			detail::State const state(_stack.data(), target, ReachableStackDepth);
			for (auto const& liveVariable: _liveOut | ranges::views::keys | ranges::views::transform(Slot::makeValueID))
				yulAssert(_stack.canBeFreelyGenerated(liveVariable) || ranges::find(_stack.data(), liveVariable) != ranges::end(_stack.data()));
			for (auto const& arg: _args)
				yulAssert(_stack.canBeFreelyGenerated(arg) || ranges::find(_stack.data(), arg) != ranges::end(_stack.data()));
		}

		static std::size_t constexpr maxIterations = 1000;
		std::size_t i = 0;
		while (i < maxIterations)
		{
			detail::State const state(_stack.data(), target, ReachableStackDepth);
			if (!shuffleStep(_stack, state))
			{
				yulAssert(state.admissible());
				break;
			}
			++i;
		}

		yulAssert(i < maxIterations, fmt::format("Maximum iterations reached on {}", stackToString(_stack.data())));
	}

private:
	/// Make a local step in stack space that should bring us closer to the target. Returns true if more shuffling
	/// is required, returns false if finished.
	static bool shuffleStep(Stack<Callback>& _stack, detail::State const& _state)
	{
		// if the stack is too large, we try to shrink it
		if (_stack.size() > _state.target().size)
		{
			if (shrinkStack(_stack, _state))
				return true;
			// couldn't shrink to required size, need to spill to memory or increase target size
			yulAssert(false, "stack too deep");
		}
		yulAssert(_stack.size() <= _state.target().size, "I1 violated: Stack size too large");

		// after this, all current slots are either in acceptable positions or at least dup-reachable
		if (auto unreachableOffset = allNecessarySlotsReachableOrFinal(_stack, _state))
		{
			// !allNecessarySlotsReachableOrFinal(ops) ≡ ¬(∀s: reachable(s) ∨ final(s)) ≡ ∃s: ¬reachable(s) ∧ ¬final(s)
			if (shrinkStack(_stack, _state))
				return true;

			yulAssert(false, fmt::format("stack too deep, couldn't reach offset {}", unreachableOffset->value));
		}

		// this will either grow the tail as needed, swap down something from args that needs to be in the tail,
		// or return false when there's nothing to be done
		if (fixTailSlot(_stack, _state))
			return true;

		// fixing tail slot fills up the tail so that now the stack must reach into the args region but also not
		// exceed it as per our first invariant
		yulAssert(_state.target().tailSize <= _stack.size() && _stack.size() <= _state.target().size);

		// if the stack reaches into the args region try fixing a slot in there until there's nothing left to be fixed
		// within the target size constraints
		if (fixArgsSlot(_stack, _state))
			return true;

		// if there are no args, we should be done now
		if (_state.target().args.empty())
			return false;
		yulAssert(_stack.size() == _state.target().size);

		// check whether we are done
		if (_state.admissible())
			return false;

		// We couldn't improve the args tail or args situation, and we are not admissible yet, so try to reduce the
		// stack size and pop something that we don't need so we make space to dup/push stuff within target size
		if (shrinkStack(_stack, _state))
			return true;

		yulAssert(false, "reached final and forbidden state");
	}

	/// Select an optimal slot to dup based on liveness analysis.
	/// Prioritizes slots that have the highest deficit with respect to liveOut counts.
	static std::optional<StackDepth> selectOptimalSlotToDup(Stack<Callback> const& _stack, detail::State const& _state)
	{
		std::optional<StackDepth> bestSlot;
		int bestDeficit = 0; // Only consider positive deficits

		// Iterate through all slots on the stack that can be DUPed
		for (StackOffset offset: _state.stackDupReachableRange() | ranges::views::reverse)
		{
			Slot const& slot = _stack[offset];

			// Skip junk slots
			if (slot.isJunk())
				continue;

			// Calculate deficit: how many more of this slot do we need?
			// Uses the deficit of slots which we need to produce more of based on usage counts in liveness.
			// Prioritizes slots that need more copies to be consumed down the line.
			int currentCount = static_cast<int>(_state.count(slot));

			int liveOutCount = 0;
			if (slot.isValueID() && _state.target().liveOut.contains(slot.valueID()))
				liveOutCount = static_cast<int>(_state.target().liveOut.count(slot.valueID()));
			int deficit = liveOutCount - currentCount;

			// Update best if this deficit is higher
			if (deficit > bestDeficit)
			{
				bestDeficit = deficit;
				bestSlot = _stack.offsetToDepth(offset);
			}
		}

		return bestSlot;
	}

	/// Dups the deepest reachable slot in the tail that is required in args
	static bool dupDeepestRelevantTailSlot(Stack<Callback>& _stack, detail::State const& _state)
	{
		// dup up the deepest slot that is required in args (or compress if unreachable)
		for (StackOffset offset: _state.stackRange())
		{
			// if we need the slot in args and there's no slot of the same kind further up
			if (
				_state.requiredInArgs(_stack[offset]) &&
				ranges::find(ranges::begin(_stack) + static_cast<std::ptrdiff_t>(offset.value) + 1, ranges::end(_stack), _stack[offset]) == ranges::end(_stack)
			)
			{
				// dup if we can
				if (_stack.dupReachable(offset))
				{
					_stack.dup(offset);
					return true;
				}

				// try to compress
				if (shrinkStack(_stack, _state))
					return true;

				yulAssert(false, fmt::format("Stack too deep: can't reach slot at offset {}", offset.value));
			}
		}
		return false;
	}

	/// If dupping an ideal slot causes a slot that will still be required to become unreachable, then dup
	/// the latter slot first
	static bool dupDeepSlotIfRequired(Stack<Callback>& _stack, detail::State const& _state)
	{
		// Check if the stack is large enough for anything to potentially become unreachable.
		if (_stack.size() < ReachableStackDepth - 1)
			return false;
		// Check whether any deep slot might still be needed later (i.e. we still need to reach it with a DUP or SWAP).
		for (StackOffset sourceOffset{0u}; sourceOffset < _stack.size() - (ReachableStackDepth - 1); ++sourceOffset.value)
		{
			// This slot needs to be moved into args and there is no tail slot of the same kind further up in the stack.
			auto const& endangeredSlot = _stack[sourceOffset];
			// no need to dup deep junk
			if (endangeredSlot.isJunk())
				continue;
			// check if we have more of the same slot further up in the stack
			bool const neededInArgs = _state.targetArgsCount(endangeredSlot) > _state.countInArgs(endangeredSlot);
			bool const needMore = _state.targetMinCount(endangeredSlot) > _state.count(endangeredSlot);
			if (neededInArgs || needMore)
			{
				// if we ever need more of a slot then this can only happen if it is something we require
				// in the arguments
				yulAssert(_state.requiredInArgs(endangeredSlot));

				auto const haveMoreAbove = [&]
				{
					for (StackOffset offset{sourceOffset.value + 1}; offset < _stack.size(); ++offset.value)
					{
						if (_stack[offset] == endangeredSlot)
							return true;
					}
					return false;
				}();

				// if we have more of the same further above, just unconditionally skip this one
				if (haveMoreAbove)
					continue;

				if (_stack.dupReachable(sourceOffset))
				{

					// if we can safely swap the current stack top with the endangered slot, we do that instead of DUP
					if (
						!_state.isArgsCompatible(sourceOffset, sourceOffset) && // the offset isn't already in the right position wrt args
						!_state.isArgsCompatible(StackOffset{_stack.size() - 1}, StackOffset{_stack.size() - 1}) && // the top isn't already in the right position wrt args
						(
							!_state.requiredInArgs(_stack.top()) || // current top can go into tail, ie it's not required as arg or
							_state.countReachable(_stack.top()) > 1 // there's more of it in reachable stack depth
						) &&
						(
							_state.target().tailSize <= sourceOffset.value ||  // sourceOffset not in tail
							!_state.requiredInTail(endangeredSlot) ||  // we're in tail but sourceOffset not needed in tail
							(_state.countInTail(endangeredSlot) > 1 && _state.requiredInTail(endangeredSlot))  // swapping source offset away from tail doesn't decrease tail correctness
						)
					)
					{
						// top can go into the tail bit, swap it down
						_stack.swap(sourceOffset);
						return true;
					}
					else
					{
						// we need more of the slot that is about to go out of reach, dup it
						_stack.dup(sourceOffset);
						return true;
					}
				}
				else
				{
					std::optional<StackDepth> depth = _stack.findSlotDepth(_stack[sourceOffset]);
					yulAssert(depth);
					// if there's a shallower slot with the same info that is reachable, skip this one
					if (*depth < _stack.offsetToDepth(sourceOffset))
						continue;

					// the slot we need something in the args region of is unreachable, try compressing the stack,
					// first looking at the top
					if (shrinkStack(_stack, _state))
						return true;

					yulAssert(false, fmt::format("Stack too deep, can't reach slot at depth {}", depth->value));
				}
			}
		}
		return false;
	}

	/// Tries to fix a slot in the args section of the stack
	static bool fixArgsSlot(Stack<Callback>& _stack, detail::State const& _state)
	{
		yulAssert(_stack.size() <= _state.target().size, "this method assumes that the stack isn't too large");
		if (_stack.size() < _state.target().tailSize)
			return false;

		// if we have at least one slot in the args section, try to fix something there
		if (!_stack.empty() && _stack.size() >= _state.target().tailSize)
		{
			StackOffset const stackTop{_stack.size() - 1};
			// if the stack top isn't where it likes to be right now, try to put it somewhere more sensible
			if (!_state.isArgsCompatible(stackTop, stackTop))
			{
				// if the stack top should go into the tail but isn't there yet and we have enough of it in args
				if (
					_state.requiredInTail(_stack[stackTop]) &&
					_state.countInTail(_stack[stackTop]) == 0 &&
					_state.countInArgs(_stack[stackTop]) > _state.targetArgsCount(_stack[stackTop])
				)
				{
					// try swapping it with something in the tail that also fixes the top
					for (StackOffset offset: _state.stackTailRange())
						if (_stack.swapReachable(offset) && _state.isArgsCompatible(offset, stackTop))
						{
							_stack.swap(offset);
							return true;
						}
					// otherwise try swapping it with something that needs to go into args
					for (StackOffset offset: _state.stackTailRange())
						if (_stack.swapReachable(offset) && _state.countInArgs(_stack[offset]) < _state.targetArgsCount(_stack[offset]))
						{
							_stack.swap(offset);
							return true;
						}
					// otherwise try swapping it with something that can be popped
					for (StackOffset offset: _state.stackTailRange())
						if (_stack.swapReachable(offset) && _stack.canBeFreelyGenerated(_stack[offset]) && !_stack[offset].isLiteralValueID())
						{
							_stack.swap(offset);
							return true;
						}
					// otherwise try swapping it with a literal
					for (StackOffset offset: _state.stackTailRange())
						if (_stack.swapReachable(offset) && _stack[offset].isLiteralValueID())
						{
							_stack.swap(offset);
							return true;
						}
				}
				// try finding a slot that is compatible with the top and also admits the current top:
				//		- could be that the top slot is used elsewhere in the args (exclude junk)
				//		- could be that the top slot is something that is only required in the tail
				for (StackOffset offset: _state.stackArgsRange())
					if (
						offset != stackTop &&
						_stack[offset] != _stack[stackTop] &&  // don't swap identical values (no-op)
						_stack.swapReachable(offset) &&
						_state.isArgsCompatible(offset, stackTop) &&
						_state.isArgsCompatible(stackTop, offset) &&
						!_state.targetArbitrary(offset)
					)
					{
						_stack.swap(offset);
						return true;
					}

				// try finding a slot in args that wants to have the top, swap that
				for (StackOffset offset: _state.stackArgsRange())
					if (
						offset != stackTop &&
						_stack[offset] != _stack[stackTop] &&  // don't swap identical values (no-op)
						_stack.swapReachable(offset) &&
						!_state.isArgsCompatible(offset, offset) &&
						_state.isArgsCompatible(stackTop, offset)
					)
					{
						_stack.swap(offset);
						return true;
					}

				// try swapping top with a tail slot that has what we need at top
				for (StackOffset tailOffset: _state.stackTailRange())
					if (
						_stack.swapReachable(tailOffset) &&
						_state.isArgsCompatible(tailOffset, stackTop) &&
						(!_state.requiredInTail(_stack[tailOffset]) || _state.countInTail(_stack[tailOffset]) > 1) &&
						// current top can safely go to tail (not needed in args, or we have excess)
						(
							!_state.requiredInArgs(_stack[stackTop]) ||
							_state.countInArgs(_stack[stackTop]) > _state.targetArgsCount(_stack[stackTop])
						)
					)
					{
						_stack.swap(tailOffset);
						return true;
					}
			}

			// swap up any slot in args that is out of position and has a slot available in args that it can occupy
			for (StackOffset offset: _state.stackArgsRange())
			{
				bool const reachable = _stack.swapReachable(offset);
				bool const identical = _state.isArgsCompatible(offset, stackTop) && !_state.targetArbitrary(stackTop);
				if (
					reachable &&
					!identical && // we wouldn't just be swapping identical things
					(
						!_state.isArgsCompatible(offset, offset) || // the slot at offset isn't final
						(_state.targetArbitrary(offset) && !_stack.slot(offset).isJunk()) // or the target is arbitrary and the current slot isn't already junk
					)
				)
				{
					// for each `targetOffset` in target args, see if we can't swap the out of position `offset` to `targetOffset`
					for (StackOffset targetOffset: _state.stackArgsRange())
						if (
							targetOffset != offset &&  // we shouldn't be looking at the very same offset
							_stack.swapReachable(targetOffset) &&  // the target offset should be within reach
							_state.isArgsCompatible(offset, targetOffset) &&  // we can put offset -> targetOffset
							!_state.isArgsCompatible(targetOffset, targetOffset)  // targetOffset doesn't like where it is
						)
						{
							if (offset != stackTop)
								// swap up slot at offset
									_stack.swap(offset);
							// bring slot at offset into fixed position
							_stack.swap(targetOffset);
							return true;
						}
				}
			}
		}

		// dup up whatever is missing
		if (_stack.size() < _state.target().size)
		{
			if (dupDeepSlotIfRequired(_stack, _state))
				return true;

			{
				StackOffset const targetOffset{_stack.size()};
				if (_state.count(_state.targetArg(targetOffset)) < _state.targetMinCount(_state.targetArg(targetOffset)))
				{
					auto const sourceDepth = _stack.findSlotDepth(_state.targetArg(targetOffset));
					if (!sourceDepth)
					{
						_stack.push(_state.targetArg(targetOffset));
						return true;
					}

					if (!_stack.dupReachable(*sourceDepth))
						yulAssert(false, fmt::format("todo: stack too deep handling, couldn't dup up arg {}", slotToString(_state.targetArg(_stack.depthToOffset(*sourceDepth)))));
					_stack.dup(*sourceDepth);
					return true;
				}
			}

			// if we can't directly produce targetOffset, take the deepest arg that we don't have enough of and dup/push that
			// First, prioritize duping args that are on the stack over pushing freely-generatable ones
			for (StackOffset offset{_state.target().tailSize}; offset < _state.target().size; ++offset.value)
			{
				Slot const& arg = _state.targetArg(offset);
				if (!arg.isJunk() && (_state.count(arg) < _state.targetMinCount(arg) || _state.countInArgs(arg) < _state.targetArgsCount(arg)))
				{
					if (auto sourceDepth = _stack.findSlotDepth(arg))
					{
						if (_stack.dupReachable(*sourceDepth))
						{
							_stack.dup(*sourceDepth);
							return true;
						}
						yulAssert(false, "stack too deep handling");
					}
					yulAssert(_stack.canBeFreelyGenerated(arg));
					_stack.push(arg);
					return true;
				}
			}

			// Try to dup the optimal slot based on liveness analysis
			if (auto slotToDup = selectOptimalSlotToDup(_stack, _state))
				_stack.dup(*slotToDup);
			else
				// If no suitable slot found, push junk
				_stack.push(Slot::makeJunk());
			return true;
		}

		// if we're at size and have to push or dup something to satisfy args
		if (_stack.size() == _state.target().size)
		{
			for (auto const& arg: _state.target().args)
				if (_state.count(arg) < _state.targetMinCount(arg))
				{
					// we have asserted that all relevant slots are reachable or final, so the arg must either be
					// within dup-reach or we can just push it
					if (auto depth = _stack.findSlotDepth(arg))
					{
						yulAssert(depth->value == 0 || _stack.swapReachable(*depth));
						// if we can't outright dup the slot, let's shrink the stack first
						if (!_stack.dupReachable(*depth))
						{
							yulAssert(shrinkStack(_stack, _state), "stack too deep, need to spill arg to memory");
							return true;
						}
						_stack.dup(*depth);
						return true;
					}
					else
					{
						yulAssert(_stack.canBeFreelyGenerated(arg));
						if (!dupDeepSlotIfRequired(_stack, _state))
							_stack.push(arg);
						return true;
					}
				}
		}
		return false;
	}

	/// Grows the tail if too small, otherwise tries swapping something down from args if its required in tail but not
	/// there yet.
	static bool fixTailSlot(Stack<Callback>& _stack, detail::State const& _state)
	{
		yulAssert(_stack.size() <= _state.target().size, "this method assumes that the stack isn't exceeding target size");
		for (StackOffset offset: _state.stackArgsRange() | ranges::views::reverse)
		{
			Slot const& slotAtOffset = _stack[offset];
			if (
				_state.requiredInTail(slotAtOffset) &&  // if we need the slot in tail
				_state.countInTail(slotAtOffset) == 0  // if we don't have the slot in tail right now
			)
			{
				// If we don't have enough copies of this slot, dup first instead of swapping.
				if (_state.count(slotAtOffset) < _state.targetMinCount(slotAtOffset))
				{
					if (_stack.dupReachable(offset))
					{
						_stack.dup(offset);
						return true;
					}
				}

				// find the lowest swappable slot in tail that needs to go to args, swap
				for (StackOffset tailOffset: _state.stackTailRange())
				{
					auto const& slotAtTailOffset = _stack[tailOffset];
					if (
						_stack.swapReachable(tailOffset) &&  // we can swap that deep
						(!_state.requiredInTail(slotAtTailOffset) || _state.countInTail(slotAtTailOffset) > 1) &&  // dont need it in tail or it's available more than once
						_state.requiredInArgs(slotAtTailOffset) &&  // we need the tail offset slot in args
						_state.targetArgsCount(slotAtTailOffset) > _state.countInArgs(slotAtTailOffset)  // we don't already have enough of it in args
					)
					{
						// bring up offset slot if necessary
						if (offset != StackOffset{_stack.size() - 1})
							_stack.swap(offset);
						// swap offset slot down into tail
						_stack.swap(tailOffset);
						return true;
					}
				}
				// find the lowest swappable slot in tail that can be popped but is no literal, swap
				for (StackOffset tailOffset: _state.stackTailRange())
					if (
						_stack.swapReachable(tailOffset) &&
						_stack.canBeFreelyGenerated(_stack[tailOffset]) &&
						!_stack[tailOffset].isLiteralValueID()
					)
					{
						// bring up offset slot if necessary
						if (offset != StackOffset{_stack.size() - 1})
							_stack.swap(offset);
						// swap offset slot down into tail
						_stack.swap(tailOffset);
						return true;
					}
				// find the lowest swappable slot in tail that is a literal, swap
				for (StackOffset tailOffset: _state.stackTailRange())
					if (
						_stack.swapReachable(tailOffset) &&
						_stack[tailOffset].isLiteralValueID()
					)
					{
						// bring up offset slot if necessary
						if (offset != StackOffset{_stack.size() - 1})
							_stack.swap(offset);
						// swap offset slot down into tail
						_stack.swap(tailOffset);
						return true;
					}
				// we needed to bring the slot into tail but couldn't, not enough stack target space -> spill to memory
				yulAssert(false, "stack too deep: couldn't swap args slot into tail without moving something else out that is required there");
			}
		}

		if (_stack.size() < _state.target().tailSize)
		{
			// if something is on the verge of going out of scope by duping something, dup that first
			if (dupDeepSlotIfRequired(_stack, _state))
				return true;

			// dup up the deepest slot that needs to go into args so we avoid having to fish it back up later
			if (dupDeepestRelevantTailSlot(_stack, _state))
				return true;

			// Try to dup the optimal slot based on liveness analysis
			if (auto slotToDup = selectOptimalSlotToDup(_stack, _state))
				_stack.dup(*slotToDup);
			else
				// If no suitable slot found, push junk
				_stack.push(Slot::makeJunk());
			return true;
		}
		return false;
	}

	/// Tries to compress the stack
	static bool shrinkStack(Stack<Callback>& _stack, detail::State const& _state)
	{
		yulAssert(!_stack.empty(), "Stack is empty, can't shrink");

		StackOffset const stackTop{_stack.size() - 1};
		// pop top if it is junk (ie actual junk, not in args, not in live out)
		if (
			_stack[stackTop].isJunk() ||
			(!_state.requiredInArgs(_stack[stackTop]) && !_state.requiredInTail(_stack[stackTop]))
		)
		{
			_stack.pop();
			return true;
		}

		// swap top to suitable position, prioritizing args region
		{
			if (_state.requiredInArgs(_stack[stackTop]))
			{
				for (StackOffset argsOffset: _state.stackArgsRange())
					if (
						_stack[argsOffset] != _stack[stackTop] &&  // don't swap identical values (no-op)
						_stack.swapReachable(argsOffset) &&
						_state.isArgsCompatible(stackTop, argsOffset) &&
						!_state.isArgsCompatible(argsOffset, argsOffset)
					)
					{
						_stack.swap(argsOffset);
						return true;
					}
			}
			// we don't need it in args but in tail
			if (!_state.requiredInArgs(_stack[stackTop]) && _state.requiredInTail(_stack[stackTop]))
			{
				// pop when at least one of the two conditions is fulfilled
				//	- the top slot is contained in tail, and we're in args or excess region
				//	- there's more than one in tail
				if (
					(
						_state.countInTail(_stack[stackTop]) >= 1 &&
						(_state.offsetInTargetArgsRegion(stackTop) || _stack.size() > _state.target().size)
					) || _state.countInTail(_stack[stackTop]) > 1
				)
				{
					_stack.pop();
					return true;
				}

				// if we need it down there, try to swap down
				for (StackOffset tailOffset: _state.stackTailRange() | ranges::views::reverse)
					if (
						_stack[tailOffset] != _stack[stackTop] &&  // don't swap identical values (no-op)
						_stack.swapReachable(tailOffset) &&  // we can reach the offset
						!(_state.requiredInTail(_stack[tailOffset]) && _state.countInTail(_stack[tailOffset]) <= 1)  // it's okay to swap the tail offset out
					)
					{
						_stack.swap(tailOffset);
						return true;
					}
			}
		}
		// pop junk (but not if JUNK is exactly what's needed at that position)
		for (StackOffset offset: _state.stackSwapReachableRange())
			if (_stack[offset].isJunk() && !_state.isArgsCompatible(offset, offset))
			{
				if (offset != stackTop && _stack[offset] != _stack[stackTop])
					_stack.swap(offset);
				_stack.pop();
				return true;
			}

		// pop something that can be freely generated except for literals
		// (but not if it's already in a compatible position)
		for (StackOffset offset: _state.stackSwapReachableRange())
			if (
				_stack.canBeFreelyGenerated(_stack[offset]) &&
				!_stack[offset].isLiteralValueID() &&
				!_state.isArgsCompatible(offset, offset)
			)
			{
				if (offset != stackTop && _stack[offset] != _stack[stackTop])
					_stack.swap(offset);
				_stack.pop();
				return true;
			}

		// pop anything that isn't in position and we have more than one of
		for (StackOffset offset: _state.stackSwapReachableRange())
			if (_state.count(_stack[offset]) > _state.targetMinCount(_stack[offset]))
			{
				if (offset != stackTop && _stack[offset] != _stack[stackTop])
					_stack.swap(offset);
				_stack.pop();
				return true;
			}
		// pop anything that can be freely generated
		for (StackOffset offset: _state.stackSwapReachableRange())
			if (_stack.canBeFreelyGenerated(_stack[offset]))
			{
				if (offset != stackTop && _stack[offset] != _stack[stackTop])
					_stack.swap(offset);
				_stack.pop();
				return true;
			}
		return false;
	}

	/// Checks if all current slots are either in a position that is compatible with the target or, if not, are dup-reachable.
	static std::optional<StackOffset> allNecessarySlotsReachableOrFinal(Stack<Callback> const& _stack, detail::State const& _state)
	{
		// check that args are either in position or reachable
		for (StackOffset offset{_state.target().tailSize}; offset < _state.target().size; ++offset.value)
			if (
				offset < _state.size() &&
				!_state.isArgsCompatible(offset, offset)
			)
			{
				// find first occurrence of the slot
				std::optional<StackDepth> depth = _stack.findSlotDepth(_state.targetArg(offset));

				if (!depth)
				{
					// if there is no occurrence of the slot anywhere, we must be able to freely generate it
					yulAssert(_stack.canBeFreelyGenerated(_state.targetArg(offset)));
				}
				else
				{
					if (!_stack.swapReachable(*depth))
						return _stack.depthToOffset(*depth);
				}
			}
		// distribution check: all we have to dup can be duped
		for (StackOffset const offset: _state.stackRange())
		{
			auto const& slotAtOffset = _stack[offset];
			// we don't have enough of the slot
			if (
				_state.count(slotAtOffset) < _state.targetMinCount(slotAtOffset) &&
				!_stack.dupReachable(offset)
			)
			{
				// find first occurrence of the slot
				std::optional<StackDepth> depth = _stack.findSlotDepth(slotAtOffset);
				// it must exist
				yulAssert(depth);
				if (!_stack.dupReachable(*depth))
					return _stack.depthToOffset(*depth);
			}
		}

		return std::nullopt;
	}
};

}
