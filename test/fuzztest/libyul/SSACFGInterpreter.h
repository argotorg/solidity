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
/**
 * Interpreter for SSA CFGs in Phi/Upsilon form.
 *
 * Runs a `ControlFlowGraphs` instance on the same `InterpreterState` that the Yul interpreter
 * (`test/tools/yulInterpreter`) uses, delegating every builtin to `EVMInstructionInterpreter`. The only semantics
 * implemented here are control flow, user function calls, and the Phi/Upsilon shadow-variable protocol, so a
 * differential run against the Yul interpreter isolates exactly the part of the pipeline that `SSACFGBuilder`
 * and the `transform/` passes are responsible for.
 */
#pragma once

#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>
#include <libyul/backends/evm/ssa/SSACFG.h>
#include <libyul/backends/evm/ssa/SSACFGTypes.h>

#include <test/tools/yulInterpreter/EVMInstructionInterpreter.h>
#include <test/tools/yulInterpreter/Interpreter.h>

#include <libsolutil/Numeric.h>

#include <map>
#include <optional>
#include <vector>

namespace solidity::yul::test
{

class SSACFGInterpreter
{
public:
	enum class Outcome
	{
		/// The main graph reached its exit.
		Returned,
		/// A terminating builtin ran (stop / return / revert / invalid / selfdestruct).
		Terminated,
		/// The step, trace or call-depth limit was hit. Execution stopped mid-way; the state is partial.
		Limit
	};

	struct RunResult
	{
		Outcome outcome;
		/// The state after the run: effect trace, memory, storage, transient storage, returndata.
		InterpreterState state;
	};

	/// Executes the main graph of @a _controlFlow starting from @a _state (inputs: calldata, limits, environment)
	/// and returns the outcome together with the final state. Termination by a builtin and limits are reported
	/// through `Outcome`, never by exception.
	/// Violations of the CFG's own invariants (executing `Unreachable`, reading a phi before any upsilon wrote its
	/// shadow, a non-continuing call returning, reaching a `Terminated` exit without termination) are reported via
	/// `yulAssert`, i.e. they throw `YulAssertion`.
	static RunResult run(InterpreterState _state, ssa::ControlFlowGraphs const& _controlFlow, bool _disableMemoryTrace);

private:
	/// Per-activation storage: SSA values, phi shadows, and the result vectors of multi-return operations.
	struct Frame
	{
		std::vector<std::optional<u256>> values;
		std::map<ssa::InstId, u256> shadows;
		std::map<ssa::InstId, std::vector<u256>> multiValues;
	};

	SSACFGInterpreter(InterpreterState& _state, ssa::ControlFlowGraphs const& _controlFlow, bool _disableMemoryTrace);

	std::vector<u256> runFunction(ssa::SSACFG const& _cfg, std::vector<u256> const& _arguments);
	void execute(ssa::SSACFG const& _cfg, Frame& _frame, ssa::InstId _id);
	void executeBuiltinCall(ssa::SSACFG const& _cfg, Frame& _frame, ssa::InstId _id);
	void executeCall(ssa::SSACFG const& _cfg, Frame& _frame, ssa::InstId _id);

	static u256 const& valueOf(Frame const& _frame, ssa::InstId _id);
	static void setValue(Frame& _frame, ssa::InstId _id, u256 _value);
	void incrementStep();

	InterpreterState& m_state;
	ssa::ControlFlowGraphs const& m_controlFlow;
	EVMInstructionInterpreter m_builtins;
	std::size_t m_callDepth = 0;
};

}
