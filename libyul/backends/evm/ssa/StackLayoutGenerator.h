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

#include <libyul/backends/evm/ssa/spill/SpillSet.h>

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

	/// the per-block stack layout plus the set of values the layout generator decided to spill to memory
	struct Result
	{
		SSACFGStackLayout layout;
		spill::SpillSet spillSet;
	};

	/// Generates the stack layout for the function graph together with the set of values that have to be spilled
	/// to memory to realize it; layout generation and def-site closure are iterated to a fixed point of the spill set
	static Result generate(
		LivenessAnalysis const& _liveness,
		CallSites const& _callSites,
		ControlFlowGraphs::FunctionGraphID _graphID,
		bool _spillingAllowed
	);

private:
	explicit StackLayoutGenerator(
		LivenessAnalysis const& _liveness,
		CallSites const& _callSites,
		ControlFlowGraphs::FunctionGraphID _graphID,
		bool _spillingAllowed,
		spill::SpillSet _initialSpillSet
	);

	void defineStackIn(SSACFG::BlockId const& _blockId);
	void visitBlock(SSACFG::BlockId const& _blockId);

	SSACFG const& m_cfg;
	LivenessAnalysis const& m_liveness;
	CallSites const& m_callSites;
	ControlFlowGraphs::FunctionGraphID m_graphID;
	bool m_hasFunctionReturnLabel;
	bool m_spillingAllowed;

	std::unique_ptr<JunkAdmittingBlocksFinder> m_junkAdmittingBlocksFinder;
	// Per-edge stack proposals for defineStackIn.
	// m_inputStackProposalsPerBlock[blockId] contains (predecessorId, edgeStack) pairs
	// representing the stack state flowing from each predecessor into the block.
	std::vector<std::vector<std::pair<SSACFG::BlockId, StackData>>> m_inputStackProposalsPerBlock;
	SSACFGStackLayout m_resultLayout;
	spill::SpillSet m_spillSet;
};

}
