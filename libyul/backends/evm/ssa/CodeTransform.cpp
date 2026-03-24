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

#include <libyul/backends/evm/ssa/CodeTransform.h>

#include <libyul/backends/evm/ssa/StackLayoutGenerator.h>
#include <libyul/backends/evm/ssa/StackShuffler.h>
#include <libyul/backends/evm/ssa/StackUtils.h>

#include <libyul/backends/evm/EVMBuiltins.h>

#include <libsolutil/Visitor.h>

#include <range/v3/view/take_last.hpp>
#include <range/v3/view/zip.hpp>

using namespace solidity::yul;
using namespace solidity::yul::ssa;

namespace
{
void assertLayoutCompatibility(StackData const& _layout1, StackData const& _layout2)
{
	auto const compatibility = checkLayoutCompatibility(_layout1, _layout2);
	yulAssert(compatibility.ok(), compatibility.formatErrors());
}
}

void CodeTransform::run
(
	AbstractAssembly& _assembly,
	ControlFlowLiveness const& _controlFlowLiveness,
	BuiltinContext& _builtinContext
)
{
	yulAssert(!_controlFlowLiveness.cfgLiveness.empty());
	ControlFlow const& controlFlow = _controlFlowLiveness.controlFlow.get();
	yulAssert(controlFlow.functionGraphs.size() == _controlFlowLiveness.cfgLiveness.size());
	FunctionLabels const functionLabels = registerFunctionLabels(_assembly, controlFlow);

	for (std::size_t functionIndex = 0; functionIndex < controlFlow.functionGraphMapping.size(); ++functionIndex)
	{
		auto const& [function, cfg] = controlFlow.functionGraphMapping[functionIndex];
		yulAssert(cfg);
		auto const callSites = gatherCallSites(*cfg);
		auto const& liveness = _controlFlowLiveness.cfgLiveness[functionIndex];
		yulAssert(liveness);
		auto const graphID = static_cast<ControlFlow::FunctionGraphID>(functionIndex);
		auto const& stackLayout = StackLayoutGenerator::generate(*liveness, callSites, graphID);
		CodeTransform transform(
			_assembly,
			_builtinContext,
			functionLabels,
			callSites,
			*cfg,
			stackLayout,
			function,
			graphID
		);
		transform(cfg->entry);
	}
}

CodeTransform::FunctionLabels CodeTransform::registerFunctionLabels(
	AbstractAssembly& _assembly, ControlFlow const& _controlFlow)
{
	FunctionLabels functionLabels;
	std::set<YulString> assignedFunctionNames;

	for (auto const& [_function, _functionGraph]: _controlFlow.functionGraphMapping)
	{
		if (!_function)
			continue;
		bool nameAlreadySeen = !assignedFunctionNames.insert(_function->name).second;
		auto const sourceID = [&]() -> std::optional<std::size_t> {
			if (_functionGraph->debugInfo && _functionGraph->debugInfo->graphDebugData)
				return _functionGraph->debugInfo->graphDebugData->astID;
			return std::nullopt;
		}();
		functionLabels[_function] = !nameAlreadySeen ?
			_assembly.namedLabel(
				_function->name.str(),
				_functionGraph->arguments.size(),
				_functionGraph->returns.size(),
				sourceID
			) :
			_assembly.newLabelId();
	}
	return functionLabels;
}

CodeTransform::CodeTransform(
	AbstractAssembly& _assembly,
	BuiltinContext& _builtinContext,
	FunctionLabels const& _functionLabels,
	CallSites const& _callSites,
	SSACFG const& _cfg,
	SSACFGStackLayout const& _stackLayout,
	Scope::Function const* _function,
	ControlFlow::FunctionGraphID _graphID
):
	m_assembly(_assembly),
	m_builtinContext(_builtinContext),
	m_functionLabels(_functionLabels),
	m_callSites(_callSites),
	m_cfg(_cfg),
	m_stackLayout(_stackLayout),
	m_graphID(_graphID),
	m_blockIsTransformed(_cfg.numBlocks(), false),
	m_blockLabels([this] {
		std::vector<AbstractAssembly::LabelID> blockLabels;
		blockLabels.reserve(m_cfg.numBlocks());
		for (std::size_t i = 0; i < m_cfg.numBlocks(); ++i)
			blockLabels.push_back(m_assembly.newLabelId());
		return blockLabels;
	}()),
	m_assemblyCallbacks{
		.cfg = &_cfg,
		.assembly = &_assembly,
		.callSites = &_callSites,
		.returnLabels = &m_returnLabels
	},
	m_stackData([&]
	{
		auto const& entryLayout = m_stackLayout[m_cfg.entry];
		yulAssert(entryLayout);
		return entryLayout->stackIn;
	}()),
	m_stack(m_stackData, m_assemblyCallbacks)
{
	if (_function)
	{
		auto const findIt = m_functionLabels.find(_function);
		yulAssert(findIt != m_functionLabels.end());
		m_assembly.appendLabel(findIt->second);
		m_assembly.setStackHeight(static_cast<int>(_function->numArguments) + (m_cfg.canContinue ? 1 : 0));
	}
	StackData expectedStackTop;
	expectedStackTop.reserve(m_cfg.arguments.size() + (m_cfg.function && m_cfg.canContinue ? 1 : 0));
		if (m_cfg.function && m_cfg.canContinue)
			expectedStackTop.push_back(StackSlot::makeFunctionReturnLabel(m_graphID));
	for (auto const& [_, valueID]: m_cfg.arguments | ranges::views::reverse)
		expectedStackTop.push_back(StackSlot::makeValueID(valueID));
	assertLayoutCompatibility(m_stack.data(), expectedStackTop);
}

void CodeTransform::operator()(SSACFG::BlockId const _blockId)
{
	yulAssert(!m_blockIsTransformed[_blockId.value], "Each block is transformed exactly once.");
	m_blockIsTransformed[_blockId.value] = true;

	m_assembly.appendLabel(m_blockLabels[_blockId.value]);

	auto const& blockLayout = m_stackLayout[_blockId];
	yulAssert(blockLayout);
	assertLayoutCompatibility(m_stack.data(), blockLayout->stackIn);
	yulAssert(static_cast<int>(m_stack.size()) == m_assembly.stackHeight());

	auto const& block = m_cfg.block(_blockId);
	yulAssert(block.operations.size() == blockLayout->operationIn.size(), "We need as many operation stack layouts as we have operations");

	for (std::size_t operationIndex = 0; operationIndex < block.operations.size(); ++operationIndex)
	{
		auto const& operationInLayout = blockLayout->operationIn[operationIndex];

		// perform the operation
		(*this)(block.operations[operationIndex], operationInLayout);
	}

	// Shuffle to the block's exit layout before dispatching the exit.
	// This ensures the condition is on top for ConditionalJump, phi pre-images are
	// in the right positions for jumps, and return values are accessible for FunctionReturn.
	StackShuffler<AssemblyCallbacks>::shuffle(m_stack, blockLayout->stackOut);

	// handle the block exit
	std::visit(util::GenericVisitor{ [this, &_blockId](auto const& exit) { (*this)(_blockId, exit); } }, block.exit);
}

void CodeTransform::operator()(SSACFG::OperationId _opId, StackData const& _operationInputLayout)
{
	SSACFG::Operation const& _operation = m_cfg.operation(_opId);
	bool const hasReturnLabel =
			std::holds_alternative<SSACFG::Call>(_operation.kind) &&
			std::get<SSACFG::Call>(_operation.kind).canContinue;

	if (hasReturnLabel)
	{
		auto const [it, inserted] = m_returnLabels.try_emplace(&std::get<SSACFG::Call>(_operation.kind).call.get(), 0);
		yulAssert(inserted, "Call sites should be unique.");
		it->second = m_assembly.newLabelId();
	}

	// check that the assembly stack height corresponds to the stack size before shuffling
	yulAssert(static_cast<int>(m_stack.size()) == m_assembly.stackHeight());

	// prepare stack for operation
	StackShuffler<AssemblyCallbacks>::shuffle(m_stack, _operationInputLayout);

	// check that the assembly stack height corresponds to the stack size after shuffling
	yulAssert(static_cast<int>(m_stack.size()) == m_assembly.stackHeight());

	// check that the stack is compatible with the operation input layout
	assertLayoutCompatibility(m_stack.data(), _operationInputLayout);

	// Assert that we have the inputs of the operation on stack top.
	yulAssert(m_stack.size() >= _operation.inputs.size());
	for (auto const& [stackEntry, input]: ranges::views::zip(
		m_stack | ranges::views::take_last(_operation.inputs.size()),
		_operation.inputs
	))
		yulAssert(stackEntry.isValueID() && stackEntry.valueID() == input);

	// if the function can continue (doesn't always abort), make sure we have the correct return label slot in place
	if (hasReturnLabel)
	{
		yulAssert(m_stack.size() > _operation.inputs.size());
		auto const returnLabelSlot = m_stack.slot(StackDepth{_operation.inputs.size()});
		yulAssert(std::holds_alternative<SSACFG::Call>(_operation.kind));
		yulAssert(
			returnLabelSlot.isFunctionCallReturnLabel() &&
			&m_callSites.functionCall(returnLabelSlot.functionCallReturnLabel()) == &std::get<SSACFG::Call>(_operation.kind).call.get()
		);
	}

	// height of the stack sans function return label and operation inputs
	std::size_t const baseHeight = m_stack.size() - _operation.inputs.size() - (hasReturnLabel ? 1 : 0);

	auto const opOriginLocation = [&]() -> langutil::SourceLocation {
		if (m_cfg.debugInfo)
			if (auto const& dbg = m_cfg.debugInfo->operationDebugData(_opId))
				return dbg->originLocation;
		return {};
	}();

	// generate code for the operation
	std::visit(util::GenericVisitor{
		[&](SSACFG::BuiltinCall const& _builtin) {
			m_assembly.setSourceLocation(opOriginLocation);
			static_cast<BuiltinFunctionForEVM const&>(_builtin.builtin.get()).generateCode(
				_builtin.call,
				m_assembly,
				m_builtinContext
			);
		},
		[&](SSACFG::Call const& _call) {
			auto const* returnLabel = util::valueOrNullptr(m_returnLabels, &_call.call.get());
			// check that if we have a return label, the call can continue
			yulAssert(!!returnLabel == _call.canContinue);
			m_assembly.setSourceLocation(opOriginLocation);
			m_assembly.appendJumpTo(
				m_functionLabels.at(&_call.function.get()),
				static_cast<int>(_call.function.get().numReturns - _call.function.get().numArguments) - (_call.canContinue ? 1 : 0),
				AbstractAssembly::JumpType::IntoFunction
			);
			// if we have a return label, append it to assembly and pop the label from the stack
			// it might also be one of the inputs that is popped here but then the label will be popped below with
			// the other inputs
			if (returnLabel)
			{
				m_assembly.appendLabel(*returnLabel);
				m_stack.pop<false>();
			}
		},
		[&](SSACFG::LiteralAssignment const&){}
	}, _operation.kind);
	// simulate that the inputs are consumed
	for (size_t i = 0; i < _operation.inputs.size(); ++i)
		m_stack.pop<false>();
	// simulate that the outputs are produced
	for (auto value: _operation.outputs)
		m_stack.push<false>(StackSlot::makeValueID(value));

	// Assert that the operation produced its proclaimed output.
	yulAssert(m_stack.size() == baseHeight + _operation.outputs.size());
	for (auto const& [stackEntry, output]: ranges::views::zip(
		m_stack.data() | ranges::views::take_last(_operation.outputs.size()),
		_operation.outputs
	))
		yulAssert(stackEntry.isValueID() && stackEntry.valueID() == output);
	yulAssert(
		static_cast<int>(m_stack.size()) == m_assembly.stackHeight(),
		fmt::format("symbolic stack size = {} =/= {} = assembly stack height", m_stack.size(), m_assembly.stackHeight())
	);
}

void CodeTransform::operator()(SSACFG::BlockId const&, SSACFG::BasicBlock::MainExit const&)
{
	yulAssert(static_cast<int>(m_stack.size()) == m_assembly.stackHeight());
	m_assembly.appendInstruction(evmasm::Instruction::STOP);
}

void CodeTransform::operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::ConditionalJump const& _conditionalJump)
{
	yulAssert(static_cast<int>(m_stack.size()) == m_assembly.stackHeight());
	// condition must be at the top of the stack
	yulAssert(m_stack.top().isValueID() && m_stack.top().valueID() == _conditionalJump.condition);
	// emit JUMPI to nonZero block
	m_assembly.appendJumpToIf(m_blockLabels[_conditionalJump.nonZero.value]);
	// update symbolic stack by popping the condition as it'll be consumed by JUMPI
	m_stack.pop<false>();

	{
		// restore stack to previous state once zero-path is handled
		ScopedSaveAndRestore restoreStack(m_stackData, StackData(m_stackData));
		yulAssert(m_stackLayout[_conditionalJump.zero]);

		// transform stack to a state in which we can jump to the zero branch
		prepareBlockExitStack(
			m_stackLayout[_conditionalJump.zero]->stackIn,
			PhiInverse(m_cfg, _currentBlock, _conditionalJump.zero)
		);
		assertLayoutCompatibility(m_stack.data(), m_stackLayout[_conditionalJump.zero]->stackIn);
		m_assembly.appendJumpTo(m_blockLabels[_conditionalJump.zero.value]);

		if (!m_blockIsTransformed[_conditionalJump.zero.value])
			(*this)(_conditionalJump.zero);
	}
	{
		yulAssert(m_stackLayout[_conditionalJump.nonZero]);
		assertLayoutCompatibility(m_stack.data(), m_stackLayout[_conditionalJump.nonZero]->stackIn);

		m_assembly.setStackHeight(static_cast<int>(m_stack.size()));
		if (!m_blockIsTransformed[_conditionalJump.nonZero.value])
			(*this)(_conditionalJump.nonZero);
	}
}

void CodeTransform::operator()(SSACFG::BlockId const& _currentBlock, SSACFG::BasicBlock::Jump const& _jump)
{
	yulAssert(static_cast<int>(m_stack.size()) == m_assembly.stackHeight());
	yulAssert(m_stackLayout[_jump.target]);
	prepareBlockExitStack(m_stackLayout[_jump.target]->stackIn, PhiInverse(m_cfg, _currentBlock, _jump.target));
	assertLayoutCompatibility(m_stack.data(), m_stackLayout[_jump.target]->stackIn);
	m_assembly.appendJumpTo(m_blockLabels[_jump.target.value]);
	if (!m_blockIsTransformed[_jump.target.value])
		(*this)(_jump.target);
}

void CodeTransform::operator()(SSACFG::BlockId const&, SSACFG::BasicBlock::FunctionReturn const& _functionReturn)
{
	yulAssert(static_cast<int>(m_stack.size()) == m_assembly.stackHeight());
	// Each CodeTransform instance handles exactly one function's CFG, so a FunctionReturn exit
	// here necessarily belongs to m_cfg.function. No identity cross-check is needed.
	yulAssert(m_cfg.function);
	yulAssert(m_cfg.canContinue);
	yulAssert(m_stack.size() == _functionReturn.returnValues.size() + 1, "There must be at least the function return label element on stack");
	yulAssert(m_stack.top().isFunctionReturnLabel());
	yulAssert(m_stack.top().functionReturnLabel() == m_graphID);
	for (std::size_t i = 0; i < _functionReturn.returnValues.size(); ++i)
	{
		auto const& returnValueSlot = m_stack.slot(StackOffset{i});
		yulAssert(returnValueSlot.isValueID());
		yulAssert(returnValueSlot.valueID() == _functionReturn.returnValues[i]);
	}
	m_assembly.appendJump(0, AbstractAssembly::JumpType::OutOfFunction);
}

void CodeTransform::operator()(SSACFG::BlockId const& _blockId, SSACFG::BasicBlock::Terminated const&)
{
	yulAssert(static_cast<int>(m_stack.size()) == m_assembly.stackHeight());
	auto const& block = m_cfg.block(_blockId);
	yulAssert(!block.operations.empty(), "Terminated block must have at least one operation.");
	std::visit(util::GenericVisitor{
		[](SSACFG::BuiltinCall const& _builtin) {
			yulAssert(_builtin.builtin.get().controlFlowSideEffects.terminatesOrReverts(), "Last operation of Terminated block must terminate or revert.");
		},
		[](SSACFG::Call const& _call) {
			yulAssert(!_call.canContinue, "Last operation of Terminated block must be a non-continuable call.");
		},
		[](SSACFG::LiteralAssignment const&) {
			yulAssert(false, "Terminated block cannot end with a literal assignment.");
		}
	}, m_cfg.operation(block.operations.back()).kind);
	// To be sure just emit another INVALID - should be removed by optimizer.
	m_assembly.appendInstruction(evmasm::Instruction::INVALID);
}

void CodeTransform::prepareBlockExitStack(StackData const& _target, PhiInverse const& _phiInverse)
{
	// pull back target to live in current variable space
	auto const pulledBackTarget = stackPreImage(_target, _phiInverse);
	// shuffle to target
	StackShuffler<AssemblyCallbacks>::shuffle(m_stack, pulledBackTarget);
	// check that shuffling was successful
	assertLayoutCompatibility(m_stack.data(), pulledBackTarget);
	// now we can simply set the target to the actual one which will take care of the application of phi functions
	m_stackData = _target;
}
