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

#include <libyul/backends/evm/ssa/analysis/Liveness.h>
#include <libyul/backends/evm/ssa/stack/spill/Emitter.h>

#include <libyul/backends/evm/ssa/stack/ShuffleTrace.h>
#include <libyul/backends/evm/ssa/stack/Stack.h>
#include <libyul/backends/evm/ssa/stack/Layout.h>

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
		analysis::ControlFlowGraphsLiveness const& _liveness,
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
		stack::CallSites const& _callSites,
		SSACFG const& _cfg,
		stack::Layout const& _stackLayout,
		stack::spill::Set const& _spillSet,
		stack::spill::StoreTraces const& _spillStoreTraces,
		ControlFlowGraphs::FunctionGraphID _graphID,
		stack::spill::MemoryAddressing const& _addressing
	);

	void operator()(SSACFG::BlockId _blockId);
	void operator()(InstId _instId, stack::ShuffleTrace const& _operationShuffle);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::MainExit const& _mainExit);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::ConditionalJump const& _conditionalJump);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::Jump const& _jump);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::FunctionReturn const& _functionReturn);
	void operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::Terminated const& _terminated);

	void prepareBlockExitStack(SSACFG::BlockId const& _currentBlock, SSACFG::BlockId const& _target);

	/// Plays back a recorded shuffle trace: applies each operation to the symbolic stack and emits its assembly.
	void playback(stack::ShuffleTrace const& _trace);
	/// Appends the assembly realizing a single recorded shuffle operation. Does not touch the symbolic stack.
	void emit(stack::ShuffleOp const& _op);

	/// If `_value` is spilled, plays back its recorded def-site trace, which brings it to the stack top and
	/// stores it into its memory slot
	void spillStore(InstId _value);

	AbstractAssembly& m_assembly;
	BuiltinContext& m_builtinContext;
	ControlFlowGraphs const& m_controlFlow;
	FunctionLabels const& m_functionLabels;
	stack::CallSites const& m_callSites;
	SSACFG const& m_cfg;
	stack::Layout const& m_stackLayout;
	stack::spill::Set const& m_spillSet;
	stack::spill::StoreTraces const& m_spillStoreTraces;
	ControlFlowGraphs::FunctionGraphID const m_graphID;

	std::vector<std::uint8_t> m_blockIsTransformed;
	std::vector<AbstractAssembly::LabelID> m_blockLabels;
	std::optional<stack::spill::Emitter> m_spillEmitter{std::nullopt};
	stack::Data m_stackData;
	stack::Stack m_stack;
	std::map<InstId, AbstractAssembly::LabelID> m_returnLabels;
};

}
