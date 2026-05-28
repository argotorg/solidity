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

#include <test/libyul/ssa/PrinterTest.h>

#include <test/libyul/Common.h>
#include <test/Common.h>

#include <libyul/backends/evm/ssa/SSACFGBuilder.h>
#include <libyul/backends/evm/ssa/transform/OptimizationPipeline.h>

#include <libyul/AsmAnalysis.h>
#include <libyul/Object.h>
#include <libyul/YulStack.h>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::yul;
using namespace solidity::yul::test::ssa;
using namespace solidity::frontend;
using namespace solidity::frontend::test;

std::unique_ptr<TestCase> PrinterTest::create(Config const& _config)
{
	return std::make_unique<PrinterTest>(_config.filename);
}

PrinterTest::PrinterTest(std::string const& _filename): TestCase(_filename)
{
	m_source = m_reader.source();
	auto dialectName = m_reader.stringSetting("dialect", "evm");
	soltestAssert(dialectName == "evm");
	m_expectation = m_reader.simpleExpectations();
}

TestCase::TestResult PrinterTest::run(std::ostream& _stream, std::string const& _linePrefix, bool const _formatted)
{
	YulStack yulStack = parseYul(m_source);
	solUnimplementedAssert(yulStack.parserResult()->subObjects.empty(), "Tests with subobjects not supported.");

	if (yulStack.hasErrors())
	{
		printYulErrors(yulStack, _stream, _linePrefix, _formatted);
		return TestResult::FatalError;
	}

	auto const* evmDialect = dynamic_cast<EVMDialect const*>(&yulStack.dialect());
	yulAssert(evmDialect);

	std::unique_ptr<yul::ssa::ControlFlowGraphs> controlFlowGraphs = yul::ssa::SSACFGBuilder::build(
		*yulStack.parserResult()->analysisInfo,
		*evmDialect,
		yulStack.parserResult()->code()->root(),
		true
	);
	yul::ssa::transform::optimize(*controlFlowGraphs);
	m_obtainedResult = controlFlowGraphs->print();

	return checkResult(_stream, _linePrefix, _formatted);
}
