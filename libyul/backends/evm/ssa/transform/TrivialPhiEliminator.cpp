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

#include <libyul/backends/evm/ssa/transform/TrivialPhiEliminator.h>

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <cstdint>
#include <map>
#include <vector>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;

void transform::eliminateTrivialPhis(SSACFG& _cfg)
{
	// Drop upsilons whose value is Unreachable (dead control-flow predecessor)
	for (BlockId const blockId: _cfg.liveBlocks())
		for (InstId const id: _cfg.block(blockId).instructions)
		{
			auto const& inst = _cfg.inst(id);
			if (inst.isUpsilon() && _cfg.isUnreachable(inst.inputs[0]))
				_cfg.replaceWithNop(id);
		}

	// Build per-phi indices
	std::map<InstId, std::vector<InstId>> upsilonsTargeting;
	std::map<InstId, std::vector<InstId>> phisReferencing;
	std::vector<InstId> worklist;
	for (std::uint32_t i = 0; i < _cfg.instructionStore().numInsts(); ++i)
	{
		InstId const id{i};
		auto const& inst = _cfg.inst(id);
		if (inst.isPhi())
			worklist.push_back(id);
		else if (inst.isUpsilon())
		{
			InstId const phi = _cfg.upsilonPhi(id);
			upsilonsTargeting[phi].push_back(id);
			InstId const value = inst.inputs[0];
			if (_cfg.kindOf(value) == InstOpcode::Phi)
				phisReferencing[value].push_back(phi);
		}
	}

	// All orphan phis can share a single Unreachable sentinel, only allocate lazily if needed
	InstId orphanUnreachable;

	while (!worklist.empty())
	{
		InstId const phi = worklist.back();
		worklist.pop_back();
		if (_cfg.kindOf(phi) != InstOpcode::Phi)
			continue;

		InstId same;
		bool nontrivial = false;
		auto const it = upsilonsTargeting.find(phi);
		if (it != upsilonsTargeting.end())
			for (InstId const ups: it->second)
			{
				if (_cfg.kindOf(ups) == InstOpcode::Nop)
					continue;
				InstId const value = _cfg.resolveIdentity(_cfg.inst(ups).inputs[0]);
				if (value == phi || _cfg.isUnreachable(value))
					continue;
				if (same.hasValue() && value != same)
				{
					nontrivial = true;
					break;
				}
				same = value;
			}
		if (nontrivial)
			continue;
		if (!same.hasValue())
		{
			// Phi has no live, non-self upsilons — it's an orphan in dead code.
			if (!orphanUnreachable.hasValue())
				orphanUnreachable = _cfg.unreachableValue();
			same = orphanUnreachable;
		}

		_cfg.replaceWithIdentity(phi, same);
		if (it != upsilonsTargeting.end())
			for (InstId const ups: it->second)
				if (_cfg.kindOf(ups) == InstOpcode::Upsilon)
					_cfg.replaceWithNop(ups);

		// Re-queue dependents and forward `phi`'s reverse-dep entries onto `same`. If `same` is itself a Phi that
		// gets eliminated later, those dependents must be reevaluated
		auto const depsIt = phisReferencing.find(phi);
		if (depsIt != phisReferencing.end())
		{
			for (InstId const dep: depsIt->second)
				worklist.push_back(dep);
			if (_cfg.kindOf(same) == InstOpcode::Phi)
			{
				auto& sameDeps = phisReferencing[same];
				sameDeps.insert(sameDeps.end(), depsIt->second.begin(), depsIt->second.end());
			}
		}
	}
}
