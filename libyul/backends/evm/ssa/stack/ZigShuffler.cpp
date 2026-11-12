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

#include <libyul/backends/evm/ssa/stack/ZigShuffler.h>

#include <libyul/backends/evm/ssa/spill/SpillSet.h>

#include <libyul/backends/evm/ssa/ShuffleTrace.h>
#include <libyul/backends/evm/ssa/StackSlot.h>

#include <libyul/Exceptions.h>

#include <array>
#include <bit>
#include <cstddef>
#include <cstdint>
#include <initializer_list>
#include <limits>
#include <memory>
#include <optional>
#include <vector>

using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::stack;

extern "C"
{

/// `Shuffle` of shuffler.zig
struct solidity_shuffler_Shuffle
{
	StackSlot const* source;
	std::size_t sourceSize;
	StackSlot const* target;
	std::size_t targetSize;
	std::uint8_t* spills;
	void* workspace;
	std::size_t reachableStackDepth;
	bool spillingAllowed;
	StackSlot const* stack;
	ShuffleOp const* trace;
	std::size_t traceSize;
	std::size_t const* sources;
};

/// `Status` of shuffler.zig
std::uint32_t solidity_shuffler_shuffle(solidity_shuffler_Shuffle* _shuffle);
std::size_t solidity_shuffler_workspaceSize();
std::size_t solidity_shuffler_workspaceAlignment();

}

namespace
{

// shuffler.zig reads and writes the slots and the operations of C++ as they are

/// Whether the members of a slot are where `StackSlot` of shuffler.zig has them: the payload in bytes 0 to 3, the
/// kind in byte 4 and the opcode of a value in byte 5
constexpr bool slotLayoutMatches(StackSlot const _slot, std::uint32_t const _payload, StackSlot::Kind const _kind)
{
	auto const bytes = std::bit_cast<std::array<std::uint8_t, sizeof(StackSlot)>>(_slot);
	return
		bytes[0] == (_payload & 0xff) &&
		bytes[1] == ((_payload >> 8) & 0xff) &&
		bytes[2] == ((_payload >> 16) & 0xff) &&
		bytes[3] == (_payload >> 24) &&
		bytes[4] == static_cast<std::uint8_t>(_kind) &&
		bytes[5] == static_cast<std::uint8_t>(InstOpcode::Unreachable);
}
static_assert(sizeof(StackSlot) == 8 && alignof(StackSlot) == 4);
static_assert(slotLayoutMatches(StackSlot::makeJunk(), 0, StackSlot::Kind::Junk));
static_assert(slotLayoutMatches(
	StackSlot::makeFunctionCallReturnLabel(0x04030201),
	0x04030201,
	StackSlot::Kind::FunctionCallReturnLabel
));
static_assert(
	static_cast<int>(StackSlot::Kind::Value) == 0 &&
	static_cast<int>(StackSlot::Kind::Junk) == 1 &&
	static_cast<int>(StackSlot::Kind::FunctionCallReturnLabel) == 2 &&
	static_cast<int>(StackSlot::Kind::FunctionReturnLabel) == 3
);
static_assert(static_cast<int>(InstOpcode::Const) == 0 && static_cast<int>(InstOpcode::Unreachable) == 5);

static_assert(sizeof(ShuffleOp) == 12 && alignof(ShuffleOp) == 4);
static_assert(offsetof(ShuffleOp, kind) == 0 && offsetof(ShuffleOp, depth) == 1 && offsetof(ShuffleOp, slot) == 4);
static_assert(
	static_cast<int>(ShuffleOp::Kind::Swap) == 0 &&
	static_cast<int>(ShuffleOp::Kind::Dup) == 1 &&
	static_cast<int>(ShuffleOp::Kind::Pop) == 2 &&
	static_cast<int>(ShuffleOp::Kind::Push) == 3 &&
	static_cast<int>(ShuffleOp::Kind::Load) == 4 &&
	static_cast<int>(ShuffleOp::Kind::Store) == 5
);

/// `Status` of shuffler.zig: any other value is a failed assertion
std::uint32_t constexpr statusDone = 0;
std::uint32_t constexpr statusBlocked = 1;
/// `OptionalOffset.none` of shuffler.zig
std::size_t constexpr noOffset = std::numeric_limits<std::size_t>::max();

/// All memory of the Zig shuffler: allocated once per thread, for all its shuffles
struct Memory
{
	Memory():
		workspace(std::make_unique_for_overwrite<std::max_align_t[]>(
			(solidity_shuffler_workspaceSize() + sizeof(std::max_align_t) - 1) / sizeof(std::max_align_t)
		))
	{
		yulAssert(solidity_shuffler_workspaceAlignment() <= alignof(std::max_align_t));
	}

	std::unique_ptr<std::max_align_t[]> workspace;
	/// The spill set of a shuffle as a byte per variable id. All bytes are 0 between two shuffles. Grows to
	/// the largest variable id of the stacks; never empty, as Zig takes no null pointer.
	std::vector<std::uint8_t> spilled = std::vector<std::uint8_t>(1);
};

/// The slots of `_stack`; not null for the empty stack, as Zig takes no null pointer
StackSlot const* slotsOf(StackData const& _stack)
{
	static StackSlot constexpr none = StackSlot::makeJunk();
	return _stack.empty() ? &none : _stack.data();
}

}

ShuffleResult stack::zigShuffle(
	StackData& _source,
	StackData const& _target,
	spill::SpillSet& _spills,
	bool const _spillingAllowed,
	std::size_t const _reachableStackDepth
)
{
	static thread_local Memory memory;
	std::vector<std::uint8_t>& spilled = memory.spilled;

	// the shuffler asks only for variables of the two stacks whether they are spilled
	for (StackData const* stack: std::initializer_list<StackData const*>{&_source, &_target})
		for (StackSlot const& slot: *stack)
			if (slot.isVariable())
			{
				std::size_t const id = slot.value().value;
				if (spilled.size() <= id)
					spilled.resize(id + 1);
				spilled[id] = _spills.isSpilled(slot);
			}

	solidity_shuffler_Shuffle shuffle{
		.source = slotsOf(_source),
		.sourceSize = _source.size(),
		.target = slotsOf(_target),
		.targetSize = _target.size(),
		.spills = spilled.data(),
		.workspace = memory.workspace.get(),
		.reachableStackDepth = _reachableStackDepth,
		.spillingAllowed = _spillingAllowed,
		.stack = nullptr,
		.trace = nullptr,
		.traceSize = 0,
		.sources = nullptr
	};
	std::uint32_t const status = solidity_shuffler_shuffle(&shuffle);

	// a plan spills only variables of the source
	if (status == statusDone)
		for (StackSlot const& slot: _source)
			if (slot.isVariable() && spilled[slot.value().value] != 0 && !_spills.isSpilled(slot))
				_spills.add(slot);
	for (StackData const* stack: std::initializer_list<StackData const*>{&_source, &_target})
		for (StackSlot const& slot: *stack)
			if (slot.isVariable())
				spilled[slot.value().value] = 0;

	if (status == statusBlocked)
		return {.status = ShuffleResult::Status::StackTooDeep};
	yulAssert(status == statusDone, "Assertion failed in shuffler.zig");

	ShuffleResult result;
	result.trace.assign(shuffle.trace, shuffle.trace + shuffle.traceSize);
	result.sourceOf.reserve(_target.size());
	for (std::size_t offset = 0; offset < _target.size(); ++offset)
		if (shuffle.sources[offset] == noOffset)
			result.sourceOf.emplace_back(std::nullopt);
		else
			result.sourceOf.emplace_back(StackOffset{shuffle.sources[offset]});
	_source.assign(shuffle.stack, shuffle.stack + _target.size());
	return result;
}
