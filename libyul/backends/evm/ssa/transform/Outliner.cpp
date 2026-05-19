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

#include <libyul/backends/evm/ssa/transform/Outliner.h>

#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>

#include <range/v3/algorithm/for_each.hpp>
#include <range/v3/algorithm/transform.hpp>
#include <range/v3/algorithm/none_of.hpp>
#include <range/v3/view/enumerate.hpp>
#include <range/v3/view/map.hpp>

#include <map>
#include <unordered_set>


using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;

namespace
{
struct BlockIdentifier
{
	ControlFlowGraphs::FunctionGraphID graphId;
	BlockId blockId;

	auto operator<=>(BlockIdentifier const& other) const = default;
};

class EquivalentBlocksDetector
{
public:
	using EquivalenceClasses = std::map<BlockIdentifier, std::vector<BlockIdentifier>>;
	explicit EquivalentBlocksDetector(ControlFlowGraphs const& _cfgs) : m_program(_cfgs)
	{
		yulAssert(m_program.mainGraph());
		auto const maybeRevert = m_program.mainGraph()->evmDialect.findBuiltin("revert");
		yulAssert(maybeRevert.has_value());
		m_revertBuiltin = maybeRevert.value();
	}
	EquivalenceClasses run() &&;
private:
	void processBlock(BlockIdentifier _identifier);
	[[nodiscard]] bool isRevertBlock(BlockIdentifier _identifier) const;
	[[nodiscard]] bool canOutlineAsFunctionWithNoArguments(BlockIdentifier _identifier) const;

	[[nodiscard]] BlockIdentifier findRepresentative(BlockIdentifier _identifier) const;
	[[nodiscard]] bool areEquivalent(BlockIdentifier _bid1, BlockIdentifier _bid2) const;

	ControlFlowGraphs const& m_program;
	EquivalenceClasses m_equivalenceClasses;
	BuiltinHandle m_revertBuiltin{};
};

bool EquivalentBlocksDetector::isRevertBlock(BlockIdentifier const _identifier) const
{
	auto const& [gid, bid] = _identifier;
	yulAssert(gid < m_program.functionGraphs.size());
	auto const& cfg = *m_program.functionGraphs[gid];
	auto const& block = cfg.block(bid);
	if (!block.isTerminationBlock())
		return false;
	yulAssert(!block.instructions.empty());
	auto const& inst = cfg.inst(block.instructions.back());
	if (inst.opcode != InstOpcode::BuiltinCall)
		return false;
	return cfg.builtinPayload(block.instructions.back()).builtin == m_revertBuiltin;
}

/**
 * Determines if a block can be outlined as a function taking no arguments.
 * This means it cannot access any (results of) operations that executed before this block.
 * In other words, as arguments for instructions it can only use constants or values computed in this block.
 * Note that the block reading/writing from/to both storage and memory is OK (if the previously stated constraint holds).
 */
bool EquivalentBlocksDetector::canOutlineAsFunctionWithNoArguments(BlockIdentifier const _identifier) const
{
	yulAssert(_identifier.graphId < m_program.functionGraphs.size());
	auto const& cfg = *m_program.functionGraphs[_identifier.graphId];
	auto const& block = cfg.block(_identifier.blockId);
	std::unordered_set<InstId::ValueType> allowed;
	for (auto const instId: block.instructions)
	{
		auto const& instruction = cfg.inst(instId);
		switch (instruction.opcode)
		{
			case InstOpcode::FunctionArg:
			case InstOpcode::Phi:
			case InstOpcode::Upsilon:
				return false;
			case InstOpcode::Const:
			case InstOpcode::MemoryGuard:
			case InstOpcode::Nop:
			case InstOpcode::Tombstone:
			case InstOpcode::Unreachable:
				break; // These instructions have no arguments
			case InstOpcode::Projection:
			{
				allowed.insert(instId.value);
				break; // Projection are deterministic if the corresponding call is deterministic
			}
			case InstOpcode::BuiltinCall:
			case InstOpcode::Call:
			case InstOpcode::Identity:
			{
				// Check if arguments are constants or instructions we have seen before in this block
				bool const deterministic = ranges::all_of(instruction.inputs, [&](InstId const arg) {
					return cfg.isLiteral(arg) || allowed.contains(arg.value);
				});
				if (!deterministic)
					return false;
				allowed.insert(instId.value);
				break;
			}
		}
	}
	return true;
}

bool EquivalentBlocksDetector::areEquivalent(BlockIdentifier const _bid1, BlockIdentifier const _bid2) const
{
	auto const& cfg1 = *m_program.functionGraphs[_bid1.graphId];
	auto const& cfg2 = *m_program.functionGraphs[_bid2.graphId];
	auto const& block1 = cfg1.block(_bid1.blockId);
	auto const& block2 = cfg2.block(_bid2.blockId);

	if (block1.instructions.size() != block2.instructions.size())
		return false;

	std::unordered_map<InstId::ValueType, InstId::ValueType> instMapping;
	auto knownToBeEquivalent = [&](auto const& idPair) {
		auto && [id1, id2] = idPair;
		if (id1 == id2)
			return true;
		auto const it = instMapping.find(id1.value);
		return it != instMapping.end() && it->second == id2.value;
	};

	for (auto&& [iid1, iid2] : ranges::views::zip(block1.instructions, block2.instructions))
	{
		auto const& inst1 = cfg1.inst(iid1);
		auto const& inst2 = cfg2.inst(iid2);
		if (inst1.opcode != inst2.opcode)
			return false;
		switch (inst1.opcode)
		{
			case InstOpcode::FunctionArg:
			case InstOpcode::Phi:
			case InstOpcode::Upsilon:
				yulAssert(false, "Blocks with these instructions should have been excluded");
			case InstOpcode::MemoryGuard:
			case InstOpcode::Nop:
			case InstOpcode::Tombstone:
			case InstOpcode::Unreachable:
			{
				yulAssert(inst1.inputs.empty());
				break;
			}
			case InstOpcode::Projection:
			{
				instMapping.insert({iid1.value, iid2.value});
				break; /* We check equivalence of the corresponding function call */
			}
			case InstOpcode::Const:
			{
				if (iid1 != iid2)
					return false;
				break;
			}
			case InstOpcode::Identity:
			case InstOpcode::BuiltinCall:
			case InstOpcode::Call:
			{
				if (inst1.opcode == InstOpcode::BuiltinCall && cfg1.builtinPayload(iid1).builtin != cfg2.builtinPayload(iid2).builtin)
					return false;
				if (inst1.opcode == InstOpcode::Call && cfg1.callPayload(iid1).graphID != cfg2.callPayload(iid2).graphID)
					return false;
				yulAssert(inst1.inputs.size() == inst2.inputs.size());
				bool const inputsEquiv = ranges::all_of(ranges::views::zip(inst1.inputs, inst2.inputs), knownToBeEquivalent);
				if (!inputsEquiv)
					return false;
				instMapping.insert({iid1.value, iid2.value});
				break;
			}
		}
	}
	return true;
}

BlockIdentifier EquivalentBlocksDetector::findRepresentative(BlockIdentifier const _identifier) const
{
	for (BlockIdentifier const other: m_equivalenceClasses | ranges::views::keys)
	{
		if (areEquivalent(_identifier, other))
			return other;
	}
	return _identifier;
}

void EquivalentBlocksDetector::processBlock(BlockIdentifier const _identifier)
{
	// For now, we are only interested in reverting blocks
	if (!isRevertBlock(_identifier))
		return;
	// Blocks that depend on the context are harder to outline, we skip them for now
	if (!canOutlineAsFunctionWithNoArguments(_identifier))
		return;
	auto const representative = findRepresentative(_identifier);
	if (representative == _identifier)
		m_equivalenceClasses.insert({_identifier, {}});
	else
		m_equivalenceClasses.at(representative).push_back(_identifier);
}

EquivalentBlocksDetector::EquivalenceClasses EquivalentBlocksDetector::run() &&
{
	for (auto const& [id, cfg]: m_program.functionGraphs | ranges::views::enumerate)
	{
		if (cfg->numBlocks() == 1)
			continue;
		auto const graphId = static_cast<ControlFlowGraphs::FunctionGraphID>(id);
		for (BlockId const blockId: cfg->liveBlocks())
			processBlock({.graphId = graphId, .blockId = blockId});
	}
	return std::move(m_equivalenceClasses);
}

} // namespace

void transform::runOutliner(ControlFlowGraphs& _cfgs)
{
	auto const& equivalenceClasses = EquivalentBlocksDetector(_cfgs).run();
	for (auto const& equivClass: equivalenceClasses)
	{
		if (equivClass.second.empty())
			continue;
		auto const& sourceBlockIdentifier = equivClass.first;
		// Create new CFG and add it to the collection
		auto const& evmDialect = _cfgs.mainGraph()->evmDialect;
		auto newCFG = std::make_unique<SSACFG>(evmDialect);
		auto const entryBlockId = newCFG->makeBlock(nullptr);
		newCFG->entry = entryBlockId;
		newCFG->canContinue = false;
		newCFG->exits.insert(entryBlockId);
		newCFG->name = "__revert_" + std::to_string(sourceBlockIdentifier.graphId) + "_" + std::to_string(sourceBlockIdentifier.blockId.value);
		newCFG->numReturns = 0;
		yulAssert(ranges::none_of(_cfgs.functionGraphs, [&](auto const& cfg) { return cfg->name == newCFG->name; }), "CFG names must be unique!");
		// copy instructions
		auto const& sourceCfg = *_cfgs.functionGraphs[sourceBlockIdentifier.graphId];
		auto const& sourceBlock = sourceCfg.block(sourceBlockIdentifier.blockId);
		std::unordered_map<InstId::ValueType, InstId::ValueType> instMapping;
		for (auto const instId: sourceBlock.instructions)
		{
			auto const& instruction = sourceCfg.inst(instId);
			switch (instruction.opcode)
			{
				case InstOpcode::Nop:
				case InstOpcode::Tombstone:
					break; // No need to copy these
				case InstOpcode::Projection:
					break; // Projections are handled together with the corresponding call
				case InstOpcode::Const:
					break; // Const instructions are handled on demand
				case InstOpcode::Unreachable:
				case InstOpcode::Phi:
				case InstOpcode::Upsilon:
				case InstOpcode::FunctionArg:
				{
					yulAssert(false, "Instruction should not be present at this stage of outlining");
				}
				case InstOpcode::MemoryGuard:
				{
					newCFG->makeMemoryGuard(entryBlockId);
					break;
				}
				case InstOpcode::Identity:
				{
					// do not copy identity, just point to the argument's translation
					yulAssert(instruction.inputs.size() == 1);
					auto arg = instruction.inputs[0];
					auto it = instMapping.find(arg.value);
					yulAssert(it != instMapping.end());
					auto [_, inserted] = instMapping.insert({instId.value, it->second});
					yulAssert(inserted);
					break;
				}
				case InstOpcode::BuiltinCall:
				case InstOpcode::Call:
				{
					std::vector<InstId> newInputs;
					newInputs.reserve(instruction.inputs.size());
					ranges::transform(
						instruction.inputs,
						std::back_inserter(newInputs),
						[&](InstId const originalInput) {
							if (sourceCfg.isLiteral(originalInput))
							{
								auto const& literalPayload = sourceCfg.literalPayload(originalInput);
								InstId newId = newCFG->newLiteral({}, literalPayload);
								instMapping.insert({originalInput.value, newId.value});
							}
							auto const it = instMapping.find(originalInput.value);
							yulAssert(it != instMapping.end());
							return InstId{it->second};
						}
					);
					InstId const newId = [&]()
					{
						if (instruction.opcode == InstOpcode::BuiltinCall)
							return newCFG->makeBuiltinCallWithProjections(
								entryBlockId,
								sourceCfg.builtinPayload(instId),
								std::move(newInputs),
								static_cast<InstructionStore::NumReturnsSizeType>(evmDialect.builtin(sourceCfg.builtinPayload(instId).builtin).numReturns),
								{}
							);
						else
							return newCFG->makeCallWithProjections(
								entryBlockId,
								sourceCfg.callPayload(instId),
								std::move(newInputs),
								static_cast<InstructionStore::NumReturnsSizeType>(sourceCfg.callPayload(instId).numReturns),
								{}
							);
					}();
					for (auto [srcOut, newOut]: ranges::views::zip(sourceCfg.outputsOf(instId), newCFG->outputsOf(newId)))
					{
						auto [_, inserted] = instMapping.insert({srcOut.value, newOut.value});
						yulAssert(inserted);
					}
					break;
				}
			}
		}
		auto newGraphId = static_cast<FunctionGraphID>(_cfgs.functionGraphs.size());
		_cfgs.functionGraphs.push_back(std::move(newCFG));

		// Replace all instructions in the corresponding basic block with a function call
		auto replaceWithCall = [&](BlockIdentifier identifier)
		{
			auto&& [graphId, blockId] = identifier;
			auto& cfg = *_cfgs.functionGraphs.at(graphId);
			auto& block = cfg.block(blockId);
			for (InstId const id: cfg.block(blockId).instructions)
				cfg.tombstone(id);
			block.instructions.clear();
			cfg.makeCallWithProjections(blockId, {.graphID = newGraphId, .canContinue = false, .numReturns = 0}, {}, 0);
		};
		replaceWithCall(equivClass.first);
		ranges::for_each(equivClass.second, replaceWithCall);
	}
}
