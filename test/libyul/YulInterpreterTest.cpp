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

#include <test/libyul/YulInterpreterTest.h>

#include <test/libyul/Common.h>

#include <test/tools/yulInterpreter/Interpreter.h>

#include <test/Common.h>

#include <libyul/YulStack.h>
#include <libyul/AsmAnalysisInfo.h>
#include <libyul/AST.h>

#include <liblangutil/DebugInfoSelection.h>
#include <liblangutil/ErrorReporter.h>

#include <boost/test/unit_test.hpp>
#include <boost/algorithm/string.hpp>

#include <fstream>

using namespace solidity;
using namespace solidity::test;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::yul;
using namespace solidity::yul::test;
using namespace solidity::frontend;
using namespace solidity::frontend::test;

YulInterpreterTest::YulInterpreterTest(std::string const& _filename):
	EVMVersionRestrictedTestCase(_filename)
{
	m_source = m_reader.source();
	m_expectation = m_reader.simpleExpectations();
	m_simulateExternalCallsToSelf = m_reader.boolSetting("simulateExternalCall", false);
}

TestCase::TestResult YulInterpreterTest::run(std::ostream& _stream, std::string const& _linePrefix, bool const _formatted)
{
	YulStack yulStack = parseYul(m_source, "", solidity::frontend::OptimiserSettings::none());

	if (yulStack.hasErrors())
	{
		printYulErrors(yulStack, _stream, _linePrefix, _formatted);
		return TestResult::FatalError;
	}

	m_obtainedResult = interpret(yulStack.parserResult());

	return checkResult(_stream, _linePrefix, _formatted);
}

std::string YulInterpreterTest::interpret(std::shared_ptr<Object const> const& _object)
{
	solAssert(_object && _object->hasCode());

	InterpreterState state;
	state.maxTraceSize = 32;
	state.maxSteps = 512;
	state.maxExprNesting = 64;
	try
	{
		Interpreter::run(
			state,
			*_object->code(),
			/*disableExternalCalls=*/ !m_simulateExternalCallsToSelf,
			/*disableMemoryTracing=*/ false
		);
	}
	catch (InterpreterTerminatedGeneric const&)
	{
	}

	std::stringstream result;
	state.dumpTraceAndState(result, false);
	return result.str();
}
