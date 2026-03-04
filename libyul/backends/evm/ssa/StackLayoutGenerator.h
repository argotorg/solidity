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

#include <libyul/backends/evm/ssa/Stack.h>
#include <libyul/backends/evm/ssa/StackLayout.h>

#include <memory>

namespace solidity::yul::ssa
{

class JunkAdmittingBlocksFinder;

class StackLayoutGenerator
{
public:
	using Slot = StackSlot;
	static SSACFGStackLayout generate(LivenessAnalysis const& _liveness, CallSites const& _callSites);

private:
	explicit StackLayoutGenerator(LivenessAnalysis const& _liveness, CallSites const& _callSites);

	void defineStackIn(SSACFG::BlockId const& _blockId);
	void visitBlock(SSACFG::BlockId const& _blockId);

	SSACFG const& m_cfg;
	LivenessAnalysis const& m_liveness;
	CallSites const& m_callSites;

	std::unique_ptr<JunkAdmittingBlocksFinder> m_junkAdmittingBlocksFinder;
	SSACFGStackLayout m_resultLayout;
};

}
