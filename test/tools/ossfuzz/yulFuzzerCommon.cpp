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
#include <test/tools/ossfuzz/yulFuzzerCommon.h>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::test::yul_fuzzer;

yulFuzzerUtil::TerminationReason yulFuzzerUtil::interpret(
	std::ostream& _os,
	bytes const& calldata,
	AST const& _ast,
	bool _disableMemoryTracing,
	bool _outputStorageOnly,
	size_t _maxSteps,
	size_t _maxTraceSize,
	size_t _maxExprNesting,
	size_t _maxInstructions
)
{
	InterpreterState state;
	state.maxTraceSize = _maxTraceSize;
	state.maxSteps = _maxSteps;
	state.maxExprNesting = _maxExprNesting;
	state.maxInstructions = _maxInstructions;
	// Add 64 bytes of pseudo-randomly generated calldata so that
	// calldata opcodes perform non trivial work.
	state.calldata = calldata;

	TerminationReason reason = TerminationReason::None;
	try
	{
		Interpreter::run(state, _ast, true, _disableMemoryTracing);
	}
	catch (StepLimitReached const&)
	{
		reason = TerminationReason::StepLimitReached;
	}
	catch (TraceLimitReached const&)
	{
		reason = TerminationReason::TraceLimitReached;
	}
	catch (ExpressionNestingLimitReached const&)
	{
		reason = TerminationReason::ExpressionNestingLimitReached;
	}
	catch (InstructionLimitReached const&)
	{
		reason = TerminationReason::InstructionLimitReached;
	}
	catch (ExplicitlyTerminated const&)
	{
		reason = TerminationReason::ExplicitlyTerminated;
	}

	if (_outputStorageOnly)
		state.dumpStorage(_os);
	else
		state.dumpTraceAndState(_os, _disableMemoryTracing);
	return reason;
}

bool yulFuzzerUtil::resourceLimitsExceeded(TerminationReason _reason)
{
	return
		_reason == yulFuzzerUtil::TerminationReason::StepLimitReached ||
		_reason == yulFuzzerUtil::TerminationReason::TraceLimitReached ||
		_reason == yulFuzzerUtil::TerminationReason::ExpressionNestingLimitReached ||
		_reason == yulFuzzerUtil::TerminationReason::InstructionLimitReached;
}
