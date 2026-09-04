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

#include <test/fuzztest/libyul/SSACFGInterpreter.h>

#include <libyul/AST.h>
#include <libyul/Exceptions.h>
#include <libyul/backends/evm/EVMDialect.h>

#include <libsolutil/Visitor.h>

#include <fmt/format.h>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;
using namespace solidity::yul::test;

namespace
{
/// Recursion guard. Both interpreters are bounded by the step limit as well, but the C++ stack is the tighter
/// resource for deep recursion, so refuse to go deeper than this and report it like a step limit.
constexpr std::size_t maxCallDepth = 1024;
}

SSACFGInterpreter::RunResult SSACFGInterpreter::run(
	InterpreterState _state,
	ControlFlowGraphs const& _controlFlow,
	bool _disableMemoryTrace
)
{
	SSACFG const* main = _controlFlow.mainGraph();
	yulAssert(main, "ControlFlowGraphs without a main graph.");
	yulAssert(main->arguments.empty(), "Main graph must not take arguments.");

	Outcome outcome = Outcome::Returned;
	{
		// The interpreter (and the EVMInstructionInterpreter it delegates builtins to) works through a reference to
		// the state for the duration of the run only; the state is moved out afterwards.
		SSACFGInterpreter interpreter(_state, _controlFlow, _disableMemoryTrace);
		try
		{
			interpreter.runFunction(*main, {});
		}
		catch (ExplicitlyTerminated const&)
		{
			outcome = Outcome::Terminated;
		}
		catch (InterpreterTerminatedGeneric const&)
		{
			outcome = Outcome::Limit;
		}
	}
	return RunResult{outcome, std::move(_state)};
}

SSACFGInterpreter::SSACFGInterpreter(
	InterpreterState& _state,
	ControlFlowGraphs const& _controlFlow,
	bool _disableMemoryTrace
):
	m_state(_state),
	m_controlFlow(_controlFlow),
	m_builtins(_controlFlow.mainGraph()->evmDialect.evmVersion(), _state, _disableMemoryTrace)
{}

u256 const& SSACFGInterpreter::valueOf(Frame const& _frame, InstId const _id)
{
	yulAssert(_id.hasValue(), "Use of an empty InstId.");
	yulAssert(_id.value < _frame.values.size(), fmt::format("InstId {} out of range.", _id.value));
	auto const& slot = _frame.values[_id.value];
	yulAssert(slot.has_value(), fmt::format("Use of value v{} before it was defined.", _id.value));
	return *slot;
}

void SSACFGInterpreter::setValue(Frame& _frame, InstId const _id, u256 _value)
{
	yulAssert(_id.value < _frame.values.size(), fmt::format("InstId {} out of range.", _id.value));
	// A value is defined by one instruction statically, but that instruction runs once per loop iteration.
	_frame.values[_id.value] = std::move(_value);
}

void SSACFGInterpreter::incrementStep()
{
	m_state.numSteps++;
	if (m_state.maxSteps > 0 && m_state.numSteps >= m_state.maxSteps)
	{
		m_state.trace.emplace_back("Interpreter execution step limit reached.");
		BOOST_THROW_EXCEPTION(StepLimitReached());
	}
}

std::vector<u256> SSACFGInterpreter::runFunction(SSACFG const& _cfg, std::vector<u256> const& _arguments)
{
	yulAssert(
		_cfg.arguments.size() == _arguments.size(),
		fmt::format("Function graph expects {} arguments, got {}.", _cfg.arguments.size(), _arguments.size())
	);
	if (++m_callDepth > maxCallDepth)
	{
		m_state.trace.emplace_back("Interpreter execution step limit reached.");
		BOOST_THROW_EXCEPTION(StepLimitReached());
	}

	Frame frame;
	frame.values.resize(_cfg.numInsts());
	for (std::size_t i = 0; i < _arguments.size(); ++i)
	{
		yulAssert(_cfg.isFunctionArg(_cfg.arguments[i]), "Graph argument is not a FunctionArg instruction.");
		setValue(frame, _cfg.arguments[i], _arguments[i]);
	}

	BlockId current = _cfg.entry;
	while (true)
	{
		SSACFG::BasicBlock const& block = _cfg.block(current);
		for (InstId const id: block.instructions)
			execute(_cfg, frame, id);

		std::optional<std::vector<u256>> result;
		std::visit(util::GenericVisitor{
			[&](SSACFG::BasicBlock::MainExit const&) { result = std::vector<u256>{}; },
			[&](SSACFG::BasicBlock::Jump const& _jump) { current = _jump.target; },
			[&](SSACFG::BasicBlock::ConditionalJump const& _jump)
			{
				current = valueOf(frame, _jump.condition) != 0 ? _jump.nonZero : _jump.zero;
			},
			[&](SSACFG::BasicBlock::FunctionReturn const& _return)
			{
				std::vector<u256> values;
				for (InstId const id: _return.returnValues)
					values.push_back(valueOf(frame, id));
				result = std::move(values);
			},
			[&](SSACFG::BasicBlock::Terminated const&)
			{
				yulAssert(
					false,
					fmt::format("Reached the Terminated exit of block #{} without execution having been terminated.", current.value)
				);
			}
		}, block.exit);
		if (result)
		{
			--m_callDepth;
			return std::move(*result);
		}
	}
}

void SSACFGInterpreter::execute(SSACFG const& _cfg, Frame& _frame, InstId const _id)
{
	incrementStep();
	SSACFG::Inst const& inst = _cfg.inst(_id);
	switch (inst.opcode)
	{
	case InstOpcode::Const:
		setValue(_frame, _id, _cfg.literalPayload(_id));
		break;
	case InstOpcode::FunctionArg:
		yulAssert(_frame.values[_id.value].has_value(), fmt::format("Unbound function argument v{}.", _id.value));
		break;
	case InstOpcode::Phi:
	{
		auto const it = _frame.shadows.find(_id);
		yulAssert(it != _frame.shadows.end(), fmt::format("Phi v{} read before any upsilon wrote its shadow.", _id.value));
		setValue(_frame, _id, it->second);
		break;
	}
	case InstOpcode::Upsilon:
		yulAssert(inst.inputs.size() == 1, "Upsilon with != 1 inputs.");
		_frame.shadows[_cfg.upsilonPhi(_id)] = valueOf(_frame, inst.inputs.front());
		break;
	case InstOpcode::Identity:
		yulAssert(inst.inputs.size() == 1, "Identity with != 1 inputs.");
		setValue(_frame, _id, valueOf(_frame, inst.inputs.front()));
		break;
	case InstOpcode::Nop:
		break;
	case InstOpcode::Projection:
	{
		yulAssert(inst.inputs.size() == 1, "Projection with != 1 inputs.");
		InstId const producer = inst.inputs.front();
		auto const it = _frame.multiValues.find(producer);
		yulAssert(it != _frame.multiValues.end(), fmt::format("Projection v{} of an operation that produced no values.", _id.value));
		std::size_t const index = _cfg.projectionIndex(_id);
		yulAssert(index < it->second.size(), fmt::format("Projection index {} out of range.", index));
		setValue(_frame, _id, it->second[index]);
		break;
	}
	case InstOpcode::MemoryGuard:
		yulAssert(m_controlFlow.memoryGuard.has_value(), "MemoryGuard instruction without a memoryguard value.");
		setValue(_frame, _id, *m_controlFlow.memoryGuard);
		break;
	case InstOpcode::BuiltinCall:
		executeBuiltinCall(_cfg, _frame, _id);
		break;
	case InstOpcode::Call:
		executeCall(_cfg, _frame, _id);
		break;
	case InstOpcode::Unreachable:
		yulAssert(false, fmt::format("Executed Unreachable instruction v{}.", _id.value));
	case InstOpcode::Tombstone:
		yulAssert(false, fmt::format("Executed Tombstone slot {}.", _id.value));
	}
}

void SSACFGInterpreter::executeBuiltinCall(SSACFG const& _cfg, Frame& _frame, InstId const _id)
{
	SSACFG::Inst const& inst = _cfg.inst(_id);
	SSACFG::BuiltinCall const& payload = _cfg.builtinPayload(_id);
	BuiltinFunctionForEVM const& builtin = _cfg.evmDialect.builtin(payload.builtin);

	// EVMInstructionInterpreter::evalBuiltin expects the full argument list, literal arguments included.
	// The CFG stores literal arguments in the payload and only the evaluated ones as inputs, so rebuild both views.
	std::vector<Expression> arguments;
	std::vector<u256> evaluated;
	std::size_t literalIndex = 0;
	std::size_t inputIndex = 0;
	for (std::size_t i = 0; i < builtin.numParameters; ++i)
		if (builtin.literalArgument(i).has_value())
		{
			yulAssert(literalIndex < payload.literalArguments.size(), "Missing literal argument in BuiltinCall payload.");
			Literal const& literal = payload.literalArguments[literalIndex++];
			arguments.emplace_back(literal);
			// Mirrors ExpressionEvaluator::evaluateArgs: unlimited string literals evaluate to a marker value.
			evaluated.push_back(literal.value.unlimited() ? u256(0xdeadbeef) : literal.value.value());
		}
		else
		{
			yulAssert(inputIndex < inst.inputs.size(), "BuiltinCall has fewer inputs than non-literal parameters.");
			// Placeholder that evalBuiltin never inspects for non-literal positions.
			arguments.emplace_back(Literal{langutil::DebugData::create(), LiteralKind::Number, LiteralValue{u256(0)}});
			evaluated.push_back(valueOf(_frame, inst.inputs[inputIndex++]));
		}
	yulAssert(inputIndex == inst.inputs.size(), "BuiltinCall has more inputs than non-literal parameters.");
	yulAssert(literalIndex == payload.literalArguments.size(), "BuiltinCall has more literal arguments than literal parameters.");

	u256 const result = m_builtins.evalBuiltin(builtin, arguments, evaluated);

	if (builtin.numReturns == 1)
		setValue(_frame, _id, result);
	else
		yulAssert(builtin.numReturns == 0, "Builtins with more than one return value are not supported.");
}

void SSACFGInterpreter::executeCall(SSACFG const& _cfg, Frame& _frame, InstId const _id)
{
	SSACFG::Inst const& inst = _cfg.inst(_id);
	SSACFG::Call const& payload = _cfg.callPayload(_id);
	SSACFG const* callee = m_controlFlow.functionGraph(payload.graphID);
	yulAssert(callee, fmt::format("Call to unknown function graph {}.", payload.graphID));

	std::vector<u256> arguments;
	for (InstId const input: inst.inputs)
		arguments.push_back(valueOf(_frame, input));

	std::vector<u256> results = runFunction(*callee, arguments);

	yulAssert(
		payload.canContinue,
		fmt::format("Call v{} is marked as non-continuing but the callee returned.", _id.value)
	);
	yulAssert(
		results.size() == payload.numReturns,
		fmt::format("Call v{} expects {} return values, callee produced {}.", _id.value, payload.numReturns, results.size())
	);
	if (payload.numReturns == 1)
		setValue(_frame, _id, results.front());
	else if (payload.numReturns > 1)
		_frame.multiValues[_id] = std::move(results);
}
