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
#include <vector>

namespace solidity::yul::ssa
{

namespace stack
{
struct ShuffleResult;
}

class JunkAdmittingBlocksFinder;

class StackLayoutGenerator
{
public:
	using Slot = StackSlot;

	enum class ShuffleRecording { Off, On };

	/// A shuffle of the final layout from `initial` to `target`, realized by `trace`
	struct ShuffleRecord
	{
		enum class Kind { Operation, ConditionalJump, FunctionReturn, Edge };
		Kind kind = Kind::Operation;
		/// the block performing the shuffle; for edges the predecessor
		SSACFG::BlockId block{};
		/// for operations: the operation the shuffle prepares the stack for
		InstId operation{};
		/// for edges: the successor
		SSACFG::BlockId successor{};
		StackData initial{};
		StackData target{};
		ShuffleTrace trace{};
	};

	/// the per-block stack layout plus the set of values the layout generator decided to spill to memory
	/// and the recorded def-site store trace of each spilled value
	struct Result
	{
		SSACFGStackLayout layout;
		spill::SpillSet spillSet;
		spill::SpillStoreTraces spillStoreTraces;
		/// the transitions of the final layout, only populated with `ShuffleRecording::On`
		std::vector<ShuffleRecord> shuffleRecords;
	};

	/// Generates the stack layout for the function graph together with the set of values that have to be spilled
	/// to memory to realize it; layout generation and def-site closure are iterated to a fixed point of the spill set
	static Result generate(
		LivenessAnalysis const& _liveness,
		CallSites const& _callSites,
		ControlFlowGraphs::FunctionGraphID _graphID,
		bool _spillingAllowed,
		ShuffleRecording _shuffleRecording = ShuffleRecording::Off
	);

private:
	explicit StackLayoutGenerator(
		LivenessAnalysis const& _liveness,
		CallSites const& _callSites,
		ControlFlowGraphs::FunctionGraphID _graphID,
		bool _spillingAllowed,
		spill::SpillSet _initialSpillSet,
		ShuffleRecording _shuffleRecording
	);

	void defineStackIn(SSACFG::BlockId const& _blockId);
	void visitBlock(SSACFG::BlockId const& _blockId);

	/// Invokes the shuffler for a shuffle of the layout and, if recording is enabled, records it completing
	/// `_record`, which identifies the shuffle
	stack::ShuffleResult shuffle(ShuffleRecord _record, StackData& _source, StackData const& _target);

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
	ShuffleRecording m_shuffleRecording;
	std::vector<ShuffleRecord> m_shuffleRecords;
};

}
