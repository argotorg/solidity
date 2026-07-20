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

#include <libyul/backends/evm/ssa/transform/ConstantConditionFolder.h>

#include <libyul/backends/evm/ssa/transform/UseCounts.h>

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <libyul/Exceptions.h>

#include <range/v3/algorithm/find.hpp>

#include <optional>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;

namespace
{

/// Returns the truth value of `_condition` if it is a compile-time constant, otherwise `nullopt`.
/// Handles literals directly and `eq(<literal>, <literal>)`.
std::optional<bool> evaluateCondition(SSACFG const& _cfg, BuiltinHandle const& _eq, InstId const _condition)
{
	InstId const condition = _cfg.resolveIdentity(_condition);

	if (_cfg.isLiteral(condition))
		return _cfg.literalPayload(condition) != 0;

	if (_cfg.kindOf(condition) == InstOpcode::BuiltinCall)
		if (_cfg.builtinPayload(condition).builtin == _eq)
		{
			auto const& inputs = _cfg.inst(condition).inputs;
			yulAssert(inputs.size() == 2);
			InstId const lhs = _cfg.resolveIdentity(inputs[0]);
			InstId const rhs = _cfg.resolveIdentity(inputs[1]);
			if (_cfg.isLiteral(lhs) && _cfg.isLiteral(rhs))
				return _cfg.literalPayload(lhs) == _cfg.literalPayload(rhs);
		}
	return std::nullopt;
}

}

void transform::foldConstantConditions(SSACFG& _cfg)
{
	std::optional<BuiltinHandle> const equalityHandle = _cfg.evmDialect.equalityFunctionHandle();
	yulAssert(equalityHandle.has_value());
	// Snapshot taken before any folding: folding only removes uses, so stale counts over-approximate
	// and a count of 1 below remains exact (the sole use is this exit's condition read).
	transform::UseCounts const useCounts(_cfg);
	for (BlockId const blockId: _cfg.liveBlocks())
	{
		auto& block = _cfg.block(blockId);
		auto const* conditionalJump = std::get_if<SSACFG::BasicBlock::ConditionalJump>(&block.exit);
		if (!conditionalJump)
			continue;

		InstId const conditionId = conditionalJump->condition;
		std::optional<bool> const condition = evaluateCondition(_cfg, *equalityHandle, conditionId);
		if (!condition)
			continue;

		BlockId const taken = *condition ? conditionalJump->nonZero : conditionalJump->zero;
		BlockId const dropped = *condition ? conditionalJump->zero : conditionalJump->nonZero;

		block.exit = SSACFG::BasicBlock::Jump{taken};

		if (dropped != taken)
		{
			// Detach the edge blockId -> dropped: drop the predecessor entry and turn the upsilons that fed
			// dropped's phis along this edge into nops (their phi pre-images are gone with the edge).
			auto& droppedEntries = _cfg.block(dropped).entries;
			auto const entry = ranges::find(droppedEntries, blockId);
			yulAssert(entry != droppedEntries.end());
			droppedEntries.erase(entry);

			for (InstId const instId: block.instructions)
				if (_cfg.isUpsilon(instId) && _cfg.inst(_cfg.upsilonPhi(instId)).block == dropped)
					_cfg.replaceWithNop(instId);
		}

		if (_cfg.isOperation(conditionId) && _cfg.inst(conditionId).block == blockId)
			if (useCounts.hasSingleUse(conditionId))
				_cfg.replaceWithNop(conditionId);
	}
}
