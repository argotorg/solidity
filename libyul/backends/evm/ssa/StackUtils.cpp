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

#include <libyul/backends/evm/ssa/StackUtils.h>

#include <libyul/backends/evm/ssa/StackShuffler.h>

#include <libevmasm/GasMeter.h>

#include <range/v3/numeric/accumulate.hpp>
#include <range/v3/view/iota.hpp>
#include <range/v3/view/zip.hpp>

#include <boost/container/flat_map.hpp>

#include <fmt/ranges.h>

using namespace solidity::yul::ssa;

void GasAccumulatingCallbacks::swap(StackDepth _depth)
{
	opGas += evmasm::GasMeter::swapGas(_depth.value, cfg.evmDialect.evmVersion());
}

void GasAccumulatingCallbacks::dup(StackDepth _depth)
{
	opGas += evmasm::GasMeter::dupGas(_depth.value, cfg.evmDialect.evmVersion());
}

void GasAccumulatingCallbacks::push(StackSlot const& _slot)
{
	if (_slot.isLiteralValue())
	{
		auto const size = numberEncodingSize(cfg.literalPayload(_slot.value()));
		opGas += evmasm::GasMeter::runGas(evmasm::pushInstruction(size), cfg.evmDialect.evmVersion());
	}
	else if (_slot.isJunk())
	{
		auto const op = cfg.evmDialect.evmVersion().hasPush0() ? evmasm::Instruction::PUSH0 : evmasm::Instruction::CODESIZE;
		opGas += evmasm::GasMeter::runGas(op, cfg.evmDialect.evmVersion());
	}
	else if (_slot.isFunctionCallReturnLabel())
	{
		// this is a jump dest, we don't really know yet how big it is going to be, just assume that it fits into
		// a 2-byte number
		opGas += evmasm::GasMeter::runGas(evmasm::Instruction::PUSH2, cfg.evmDialect.evmVersion());
	}
	else
	{
		// Spilled SSA value
		yulAssert(_slot.isValue(), "unexpected slot kind in GasAccumulatingCallbacks::push");
		opGas += evmasm::GasMeter::runGas(evmasm::Instruction::PUSH32, cfg.evmDialect.evmVersion());
		opGas += evmasm::GasMeter::runGas(evmasm::Instruction::MLOAD, cfg.evmDialect.evmVersion());
	}
}

void GasAccumulatingCallbacks::pop()
{
	opGas += evmasm::GasMeter::runGas(evmasm::Instruction::POP, cfg.evmDialect.evmVersion());
}

StackData solidity::yul::ssa::stackPreImage(SSACFG const& _cfg, StackData _stack, PhiInverse const& _phiInverse)
{
	if (!_phiInverse.noOp())
		for (auto& slot: _stack)
			if (slot.isValue())
			{
				auto const preImage = _phiInverse(slot.value());
				slot = StackSlot::makeValue(_cfg, preImage);
			}
	return _stack;
}

OptimalTarget solidity::yul::ssa::findOptimalTarget
(
	StackData const& _stackData,
	StackData const& _targetArgs,
	StackSlotLiveness const& _targetLiveOut,
	bool const _canIntroduceJunk,
	bool const _hasFunctionReturnLabel,
	spill::SpillSet const& _spillSet,
	bool const _spillingAllowed
)
{
	std::size_t const minSize = _targetLiveOut.size() + _targetArgs.size() + (_hasFunctionReturnLabel ? 1 : 0);
	boost::container::flat_map<StackSlot, std::size_t> deficit;
	for (auto const& slot: _targetLiveOut | ranges::views::keys)
		deficit[slot]++;
	for (auto const& arg: _targetArgs)
		deficit[arg]++;
	for (auto const& slot: _stackData)
		if (auto it = deficit.find(slot); it != deficit.end())
			it->second = it->second > 0 ? it->second - 1 : 0;

	std::size_t const pivot = _canIntroduceJunk ? _stackData.size() + _targetArgs.size() : _stackData.size() + ranges::accumulate(deficit | ranges::views::values, 0u);
	std::size_t const startSize = std::max(pivot, minSize);
	static std::size_t constexpr maxUpwardExpansion = 32;

	StackData data;
	data.reserve(startSize + maxUpwardExpansion);
	spill::SpillSet spillSet;
	auto const evaluateCost = [&](std::size_t const _targetSize) -> std::size_t
	{
		spillSet = _spillSet;
		data = _stackData;
		Stack<OpsCountingCallbacks> countOpsStack(data, {});
		StackShufflerResult const result = StackShuffler<OpsCountingCallbacks>::shuffleWithSpillDiscovery(
			countOpsStack,
			_targetArgs,
			_targetLiveOut,
			_targetSize,
			spillSet
		);
		yulAssert(data.size() == _targetSize);
		yulAssert(result.status == StackShufflerResult::Status::Admissible);
		std::size_t const cost = countOpsStack.callbacks().numOps + 1000 * spillSet.numSpilled();
		return cost;
	};

	std::size_t bestCost = evaluateCost(startSize);
	StackData bestData = data;
	spill::SpillSet bestSpillSet = spillSet;

	// On non-reverting paths, only search downward from pivot to avoid growing the stack.
	// On reverting paths, search in both directions since stack cleanup doesn't matter.
	static std::size_t constexpr stopAfter = 3;
	std::size_t consecutiveIncreases = 0;
	// search downward
	{
		std::size_t size = startSize;
		while (size > minSize)
		{
			--size;
			auto const cost = evaluateCost(size);
			if (cost <= bestCost)
			{
				bestCost = cost;
				bestData = data;
				bestSpillSet = spillSet;
				consecutiveIncreases = 0;
			}
			else if (++consecutiveIncreases >= stopAfter)
				break;
		}
	}
	// search upward (only on reverting paths)
	if (_canIntroduceJunk)
	{
		consecutiveIncreases = 0;
		for (std::size_t size = startSize + 1; size <= startSize + maxUpwardExpansion; ++size)
		{
			auto const cost = evaluateCost(size);
			if (cost < bestCost)
			{
				bestCost = cost;
				bestData = data;
				bestSpillSet = spillSet;
				consecutiveIncreases = 0;
			}
			else if (++consecutiveIncreases >= stopAfter)
				break;
		}
	}

	yulAssert(_spillingAllowed || bestSpillSet.numSpilled() == _spillSet.numSpilled(), "Spilling not allowed, stack too deep.");
	return OptimalTarget{std::move(bestData), std::move(bestSpillSet)};
}

CallSites solidity::yul::ssa::gatherCallSites(SSACFG const& _cfg)
{
	CallSites result;
	std::vector<std::uint8_t> visited(_cfg.numBlocks(), false);
	visited[_cfg.entry.value] = true;
	std::vector<SSACFG::BlockId> toVisit;
	toVisit.reserve(_cfg.numBlocks());
	toVisit.push_back(_cfg.entry);

	while (!toVisit.empty())
	{
		auto const blockId = toVisit.back();
		toVisit.pop_back();
		auto const& block = _cfg.block(blockId);
		block.forEachExit([&toVisit, &visited](SSACFG::BlockId const& _exitBlockId){
			if (!visited[_exitBlockId.value])
			{
				visited[_exitBlockId.value] = true;
				toVisit.push_back(_exitBlockId);
			}
		});

		for (InstId const instId: block.instructions)
		{
			auto const& inst = _cfg.inst(instId);
			if (inst.opcode != InstOpcode::Call)
				continue;
			if (_cfg.callPayload(instId).canContinue)
				result.addCallSite(instId);
		}
	}
	return result;
}

std::string ValidationResult::formatErrors() const
{
	return fmt::format("{}", fmt::join(m_errors, "\n"));
}

ValidationResult solidity::yul::ssa::checkLayoutCompatibility(StackData const& _current, StackData const& _desired)
{
	ValidationResult result;
	if (_current.size() != _desired.size())
		return result.addError(fmt::format(
			"size mismatch: {} = len({}) =/= len({}) = {}",
			_current.size(), stackToString(_current), stackToString(_desired), _desired.size()
		));
	for (auto&& [index, currentSlot, desiredSlot]: ranges::zip_view(ranges::views::iota(0), _current, _desired))
		if (!desiredSlot.isJunk() && currentSlot != desiredSlot)
			result.addError(fmt::format(
				"stack element mismatch: {} = {}[{}] =/= {}[{}] = {}",
				slotToString(currentSlot),
				stackToString(_current),
				index,
				stackToString(_desired),
				index,
				slotToString(desiredSlot)
			));
	return result;
}
