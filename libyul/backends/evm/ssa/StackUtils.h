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

#include <string>
#include <vector>

namespace solidity::yul::ssa
{

class ValidationResult
{
public:
	bool ok() const { return m_errors.empty(); }
	std::string formatErrors() const;
	ValidationResult& addError(std::string _msg) { m_errors.push_back(std::move(_msg)); return *this; }
	std::vector<std::string> const& errors() const { return m_errors; }
private:
	std::vector<std::string> m_errors;
};

struct CountingInstructionsCallbacks
{
	std::size_t numOps = 0;
	void swap(StackDepth) { ++numOps; }
	void dup(StackDepth) { ++numOps; }
	void push(StackSlot const&) { ++numOps; }
	void pop() { ++numOps; }
};

/// Transform stack data by replacing all its phi variables with their respective preimages.
StackData stackPreImage(StackData _stack, PhiInverse const& _phiInverse);

std::size_t findOptimalTargetSize(StackData const& _stackData, StackData const& _targetArgs, LivenessAnalysis::LivenessData const& _targetLiveOut, bool _canIntroduceJunk, bool _hasFunctionReturnLabel);

CallSites gatherCallSites(SSACFG const& _cfg);

/// Checks that _current and _desired have the same size and that each slot matches,
/// treating junk slots in _desired as wildcards.
ValidationResult checkLayoutCompatibility(StackData const& _current, StackData const& _desired);

}
