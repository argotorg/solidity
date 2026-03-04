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

#include <libyul/backends/evm/ssa/PhiInverse.h>
#include <libyul/backends/evm/ssa/Stack.h>

namespace solidity::yul::ssa
{

struct CountingInstructionsCallbacks
{
	std::size_t numOps = 0;
	void swap(std::size_t) { ++numOps; }
	void dup(std::size_t) { ++numOps; }
	void push(StackSlot const&) { ++numOps; }
	void pop() { ++numOps; }
};

/// Transform stack data by replacing all its phi variables with their respective preimages.
StackData stackPreImage(StackData _stack, PhiInverse const& _phiInverse);

std::size_t findOptimalTargetSize(StackData const& _stackData, StackData const& _targetArgs, LivenessAnalysis::LivenessData const& _targetLiveOut, bool _canIntroduceJunk);

CallSites gatherCallSites(SSACFG const& _cfg);

}
