// SPDX-License-Identifier: GPL-3.0
/**
 * @file SubroutineEntryMarker.cpp
 * Post-optimisation pass for EIP-7979 code: a tag that is reached from more
 * than one subroutine entry becomes a subroutine entry itself (CALLDEST).
 */

#include <libevmasm/SubroutineEntryMarker.h>

#include <libevmasm/SemanticInformation.h>

#include <map>
#include <set>
#include <vector>

using namespace solidity;
using namespace solidity::evmasm;

namespace
{

/// The entry of top-level code.
constexpr int64_t outerEntry = -1;

struct WorkItem
{
	size_t index;
	int64_t entry;
};

/// Index of the Tag item for each local tag id.
std::map<u256, size_t> tagPositions(AssemblyItems const& _items)
{
	std::map<u256, size_t> positions;
	for (size_t i = 0; i < _items.size(); ++i)
		if (_items[i].type() == Tag)
			positions[_items[i].data()] = i;
	return positions;
}

/// The local tag pushed by the PushTag at @a _i, if it is local.
std::optional<size_t> localTagTarget(AssemblyItems const& _items, size_t _i, std::map<u256, size_t> const& _tagPositions)
{
	if (_items[_i].type() != PushTag)
		return std::nullopt;
	auto [subId, tagId] = _items[_i].splitForeignPushTag();
	if (subId != std::numeric_limits<SubAssemblyID>::max())
		return std::nullopt;
	auto it = _tagPositions.find(u256(tagId));
	if (it == _tagPositions.end())
		return std::nullopt;
	return it->second;
}

/// One traversal. Returns the tags that were reached from more than one entry
/// and are not subroutine entries yet.
std::set<size_t> conflictingTags(AssemblyItems const& _items)
{
	auto const positions = tagPositions(_items);
	std::map<size_t, int64_t> visited;
	std::set<size_t> conflicts;
	std::vector<WorkItem> work{{0, outerEntry}};

	while (!work.empty())
	{
		auto [i, entry] = work.back();
		work.pop_back();
		if (i >= _items.size())
			continue;

		AssemblyItem const& item = _items[i];
		// Arriving at a subroutine entry other than by starting it resets the entry.
		if (item.isSubroutineEntry())
			entry = static_cast<int64_t>(i);

		auto const [it, inserted] = visited.emplace(i, entry);
		if (!inserted)
		{
			if (it->second != entry && item.type() == Tag && !item.isSubroutineEntry())
				conflicts.insert(i);
			continue;
		}

		// A PushTag followed by a control transfer: the pushed tag is the target.
		if (item.type() == PushTag && i + 1 < _items.size() && _items[i + 1].type() == Operation)
		{
			Instruction const next = _items[i + 1].instruction();
			if (next == Instruction::JUMP || next == Instruction::JUMPI || next == Instruction::CALLSUB)
			{
				auto const target = localTagTarget(_items, i, positions);
				if (target)
				{
					if (next == Instruction::CALLSUB)
						work.push_back({*target, static_cast<int64_t>(*target)});
					else
						work.push_back({*target, entry});
				}
				// Continue after the transfer: the call's return point, the
				// conditional jump's fall-through; nothing after a plain JUMP.
				if (next != Instruction::JUMP)
					work.push_back({i + 2, entry});
				continue;
			}
		}

		if (item.type() == Operation)
		{
			Instruction const instr = item.instruction();
			if (SemanticInformation::terminatesControlFlow(instr) || instr == Instruction::JUMP)
				continue;
			if (instr == Instruction::JUMPI)
			{
				// Dynamic conditional jump: only the fall-through is known.
				work.push_back({i + 1, entry});
				continue;
			}
		}

		// A lone PushTag is a jump target reached some other way; be conservative.
		if (item.type() == PushTag)
			if (auto const target = localTagTarget(_items, i, positions))
				work.push_back({*target, entry});

		work.push_back({i + 1, entry});
	}
	return conflicts;
}

}

bool SubroutineEntryMarker::markSharedBlocks(AssemblyItems& _items)
{
	bool changed = false;
	// Marking a tag changes the entry of everything reached from it, so iterate
	// to a fixpoint; each round marks at least one tag, so it ends.
	for (size_t round = 0; round < _items.size(); ++round)
	{
		std::set<size_t> const conflicts = conflictingTags(_items);
		if (conflicts.empty())
			break;
		for (size_t const i: conflicts)
			_items[i].setSubroutineEntry();
		changed = true;
	}
	return changed;
}
