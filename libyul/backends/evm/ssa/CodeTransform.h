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

#include <libyul/backends/evm/ssa/spill/Emitter.h>

#include <libyul/backends/evm/ssa/ShuffleTrace.h>
#include <libyul/backends/evm/ssa/Stack.h>
#include <libyul/backends/evm/ssa/StackLayout.h>

#include <libyul/backends/evm/AbstractAssembly.h>

namespace solidity::yul
{
struct BuiltinContext;
}
namespace solidity::yul::ssa
{

class CodeTransform
{
public:
	static void run(
		AbstractAssembly& _assembly,
		ControlFlowGraphs& _controlFlowGraphs,
		ControlFlowGraphsLiveness const& _liveness,
		BuiltinContext& _builtinContext
	);

private:
	using FunctionLabels = std::map<ControlFlowGraphs::FunctionGraphID, AbstractAssembly::LabelID>;

	static FunctionLabels registerFunctionLabels(
		AbstractAssembly& _assembly,
		ControlFlowGraphs const& _controlFlow
	);

	CodeTransform(
		AbstractAssembly& _assembly,
		BuiltinContext& _builtinContext,
		ControlFlowGraphs const& _controlFlow,
		FunctionLabels const& _functionLabels,
		CallSites const& _callSites,
		SSACFG const& _cfg,
		SSACFGStackLayout const& _stackLayout,
		spill::SpillSet const& _spillSet,
		spill::SpillStoreTraces const& _spillStoreTraces,
		ControlFlowGraphs::FunctionGraphID _graphID,
		spill::MemoryAddressing const& _addressing
	);

	void operator()(SSACFG::BlockId _blockId);
	void operator()(InstId _instId, ShuffleTrace const& _operationShuffle);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::MainExit const& _mainExit);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::ConditionalJump const& _conditionalJump);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::Jump const& _jump);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::FunctionReturn const& _functionReturn);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::Terminated const& _terminated);

	void prepareBlockExitStack(SSACFG::BlockId const& _currentBlock, SSACFG::BlockId const& _target);

	/// Plays back a recorded shuffle trace: applies each operation to the symbolic stack and emits its assembly.
	void playback(ShuffleTrace const& _trace);
	/// Appends the assembly realizing a single recorded shuffle operation. Does not touch the symbolic stack.
	void emit(ShuffleOp const& _op);

	/// If `_value` is spilled, plays back its recorded def-site trace, which brings it to the stack top and
	/// stores it into its memory slot
	void spillStore(InstId _value);

	/// The return label of the call `_instId`, created on first use
	AbstractAssembly::LabelID returnLabel(InstId _instId);

	AbstractAssembly& m_assembly;
	BuiltinContext& m_builtinContext;
	ControlFlowGraphs const& m_controlFlow;
	FunctionLabels const& m_functionLabels;
	CallSites const& m_callSites;
	SSACFG const& m_cfg;
	SSACFGStackLayout const& m_stackLayout;
	spill::SpillSet const& m_spillSet;
	spill::SpillStoreTraces const& m_spillStoreTraces;
	ControlFlowGraphs::FunctionGraphID const m_graphID;

	std::vector<std::uint8_t> m_blockIsTransformed;
	std::vector<AbstractAssembly::LabelID> m_blockLabels;
	std::optional<spill::Emitter> m_spillEmitter{std::nullopt};
	StackData m_stackData;
	Stack m_stack;
	std::map<InstId, AbstractAssembly::LabelID> m_returnLabels;
};

}
