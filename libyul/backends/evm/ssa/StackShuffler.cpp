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

#include <libyul/backends/evm/ssa/StackShuffler.h>

#include <range/v3/algorithm/count.hpp>
#include <range/v3/view/enumerate.hpp>

using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::detail;

Target::Target(
	StackData const& _args,
	StackSlotLiveness const& _liveOut,
	std::size_t const _targetSize,
	spill::SpillSet const* _spilledVariables
):
	args(_args),
	liveOut(_liveOut),
	size(_targetSize),
	tailSize(_targetSize - _args.size())
{
	minCount.reserve(_args.size() + _liveOut.size());
	for (auto const& arg: _args)
		if (!arg.isJunk() && !slotIsSpilled(arg, _spilledVariables))
			++minCount[arg];
	for (auto const& liveSlot: _liveOut | ranges::views::keys)
		if (!slotIsSpilled(liveSlot, _spilledVariables))
			++minCount[liveSlot];
}

State::State(StackData const& _stackData, Target const& _target, spill::SpillSet const* const _spilledVariables, std::size_t const _reachableStackDepth):
	m_stackData(_stackData),
	m_target(_target),
	m_spilledVariables(_spilledVariables),
	m_reachableStackDepth(_reachableStackDepth)
{
	m_histogram.reserve(_stackData.size());
	m_histogramReachable.reserve(_stackData.size());
	m_histogramTail.reserve(_stackData.size());
	m_histogramArgs.reserve(_target.args.size());
	for (auto const& [i, slot]: _stackData | ranges::views::enumerate)
	{
		// we don't care about junk in the tail
		if (i < _target.tailSize && slot.isJunk())
			continue;
		// we purposefully skip over junk in the target args as they are always 'correct'
		if (i >= _target.tailSize && i < _target.size && _target.args[i - _target.tailSize].isJunk())
			continue;

		++m_histogram[slot];
		if (i < _target.tailSize)
			++m_histogramTail[slot];
		else if (i < _target.size)
			++m_histogramArgs[slot];
		if (_stackData.size() - i - 1 < _reachableStackDepth)
			++m_histogramReachable[slot];
	}
}

std::size_t State::size() const
{
	return m_stackData.size();
}

std::size_t State::count(StackSlot const& _slot) const
{
	return solidity::util::valueOrDefault(m_histogram, _slot, static_cast<size_t>(0));
}

std::size_t State::countInArgs(StackSlot const& _slot) const
{
	return solidity::util::valueOrDefault(m_histogramArgs, _slot, static_cast<size_t>(0));
}

std::size_t State::countInTail(StackSlot const& _slot) const
{
	return solidity::util::valueOrDefault(m_histogramTail, _slot, static_cast<size_t>(0));
}

std::size_t State::countReachable(StackSlot const& _slot) const
{
	return solidity::util::valueOrDefault(m_histogramReachable, _slot, static_cast<size_t>(0));
}

std::size_t State::targetMinCount(StackSlot const& _slot) const
{
	return solidity::util::valueOrDefault(m_target.minCount, _slot, static_cast<size_t>(0));
}

std::size_t State::targetArgsCount(StackSlot const& _slot) const
{
	return static_cast<size_t>(ranges::count(m_target.args, _slot));
}

bool State::admissible() const
{
	if (m_target.size != m_stackData.size())
		return false;

	// check if the args are correct
	for (size_t i = 0; i < m_target.args.size(); ++i)
		if (!isArgsCompatible(StackOffset{m_stackData.size() - i - 1}, StackOffset{m_stackData.size() - i - 1}))
			return false;

	// check if the distribution is correct (implying that the stack is admissible as JUNK target args are not counted)
	for (auto const& [targetSlot, targetMinCount]: m_target.minCount)
		if (count(targetSlot) < targetMinCount)
			return false;
	return true;
}

bool State::requiredInArgs(StackSlot const& _slot) const
{
	return ranges::find(m_target.args, _slot) != ranges::end(m_target.args);
}

bool State::requiredInTail(StackSlot const& _slot) const
{
	if (!_slot.isValue() || !m_target.liveOut.contains(_slot))
		return false;
	// Spilled values can be rematerialized, so they need not occupy a tail slot.
	return !slotIsSpilled(_slot);
}

bool State::offsetInTargetArgsRegion(StackOffset const _offset) const
{
	return _offset.value >= m_target.tailSize && _offset.value < m_target.size;
}

StackSlot const& State::targetArg(StackOffset const _targetOffset) const
{
	yulAssert(offsetInTargetArgsRegion(_targetOffset));
	return m_target.args[_targetOffset.value - m_target.tailSize];
}

bool State::isArgsCompatible(StackOffset const _sourceOffset, StackOffset const _targetOffset) const
{
	if (_sourceOffset >= m_stackData.size() || !offsetInTargetArgsRegion(_targetOffset))
		return false;
	auto const& arg = targetArg(_targetOffset);
	return arg.isJunk() || m_stackData[_sourceOffset.value] == arg;
}

bool State::targetArbitrary(StackOffset const _targetOffset) const
{
	return targetArg(_targetOffset).isJunk();
}

bool State::isSourceCompatible(StackOffset const _sourceOffset1, StackOffset const _sourceOffset2) const
{
	return _sourceOffset1 < m_stackData.size() &&
		_sourceOffset2 < m_stackData.size() &&
		m_stackData[_sourceOffset1.value] == m_stackData[_sourceOffset2.value];
}

bool State::isSafeToSwapWithTop(StackOffset const _offset) const
{
	auto const& top = m_stackData.back();
	yulAssert(_offset.value < size());
	auto const& slot = m_stackData[_offset.value];
	return !isArgsCompatible(_offset, _offset) && // the offset isn't already in the right position wrt args
		!isArgsCompatible(StackOffset{size() - 1}, StackOffset{size() - 1}) && // the top isn't already in the right position wrt args
		(
			!requiredInArgs(top) || // current top can go into tail, ie it's not required as arg or
			countReachable(top) > 1 // there's more of it in reachable stack depth
		) &&
		(
			target().tailSize <= _offset.value ||  // sourceOffset not in tail
			!requiredInTail(slot) ||  // we're in tail but sourceOffset not needed in tail
			(countInTail(slot) > 1 && requiredInTail(slot))  // swapping source offset away from tail doesn't decrease tail correctness
		);
}

std::optional<StackOffset> State::canSwapWithNonTopArg(StackOffset const _offset) const
{
	auto const& slot = m_stackData[_offset.value];
	for (auto argOffset: stackArgsRange())
	{
		if (argOffset.value == m_stackData.size() - 1)
			continue;
		auto const& argSlot = m_stackData[argOffset.value];
		if (slot == argSlot)
			continue;
		bool const goodCandidateForSwap = !isArgsCompatible(argOffset, argOffset) && !requiredInArgs(argSlot);
		if (goodCandidateForSwap)
			return argOffset;
	}
	return std::nullopt;
}

Target const& State::target() const
{
	return m_target;
}

bool State::willRequireShrinking() const
{
	std::size_t deficit = 0u;
	for (auto const& [slot, minCount]: target().minCount)
	{
		if (slot.isJunk())
			continue;
		auto const currentCount = count(slot);
		if (currentCount < minCount)
			deficit += minCount - currentCount;
	}
	return deficit + size() > target().size;
}

std::optional<StackDepth> State::findDeepestIncorrectArgSlot() const
{
	for (StackOffset const offset: stackArgsRange())
	{
		if (!isArgsCompatible(offset, offset))
			return StackDepth{m_stackData.size() - offset.value};
	}
	return std::nullopt;
}
