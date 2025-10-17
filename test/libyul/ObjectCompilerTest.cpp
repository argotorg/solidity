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

#include <test/libyul/ObjectCompilerTest.h>

#include <test/libsolidity/util/SoltestErrors.h>

#include <test/Common.h>
#include <test/libyul/Common.h>

#include <libyul/YulStack.h>

#include <libevmasm/Assembly.h>
#include <libevmasm/Disassemble.h>
#include <libevmasm/Instruction.h>

#include <liblangutil/DebugInfoSelection.h>

#include <boost/algorithm/string.hpp>

#include <ostream>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::yul;
using namespace solidity::yul::test;
using namespace solidity::frontend;
using namespace solidity::frontend::test;
using namespace solidity::test;

std::map<ObjectCompilerTest::Output, std::string> const ObjectCompilerTest::c_outputLabels = {
	{ObjectCompilerTest::Output::Assembly, "Assembly"},
	{ObjectCompilerTest::Output::Bytecode, "Bytecode"},
	{ObjectCompilerTest::Output::Opcodes, "Opcodes"},
	{ObjectCompilerTest::Output::SourceMappings, "SourceMappings"},
};

ObjectCompilerTest::ObjectCompilerTest(std::string const& _filename):
	EVMVersionRestrictedTestCase(_filename)
{
	m_source = m_reader.source();
	m_optimisationPreset = m_reader.enumSetting<OptimisationPreset>(
		"optimizationPreset",
		{
			{"none", OptimisationPreset::None},
			{"minimal", OptimisationPreset::Minimal},
			{"standard", OptimisationPreset::Standard},
			{"full", OptimisationPreset::Full},
		},
		"minimal"
	);

	m_selectedOutputs = m_reader.enumSetSetting(
		"outputs",
		c_outputLabels,
		c_outputLabels | ranges::views::keys | ranges::to<std::set>
	);

	m_expectation = m_reader.simpleExpectations();
}

TestCase::TestResult ObjectCompilerTest::run(std::ostream& _stream, std::string const& _linePrefix, bool const _formatted)
{
	YulStack yulStack = parseYul(m_source, "source", OptimiserSettings::preset(m_optimisationPreset));
	MachineAssemblyObject obj;
	if (!yulStack.hasErrors())
	{
		yulStack.optimize();
		obj = yulStack.assemble(YulStack::Machine::EVM);
	}
	if (yulStack.hasErrors())
	{
		printYulErrors(yulStack, _stream, _linePrefix, _formatted);
		return TestResult::FatalError;
	}

	solAssert(obj.bytecode);
	solAssert(obj.sourceMappings);

	auto const produceOutput = [&](Output _output) {
		switch (_output)
		{
		case Output::Assembly: return obj.assembly->assemblyString(yulStack.debugInfoSelection());
		case Output::Bytecode: return util::toHex(obj.bytecode->bytecode);
		case Output::Opcodes: return evmasm::disassemble(obj.bytecode->bytecode, CommonOptions::get().evmVersion());
		case Output::SourceMappings: return *obj.sourceMappings;
		}
		unreachable();
	};

	for (Output output: c_outputLabels | ranges::views::keys)
		if (m_selectedOutputs.contains(output))
		{
			if (!m_obtainedResult.empty() && m_obtainedResult.back() != '\n')
				m_obtainedResult += "\n";

			// Don't trim on the left to avoid stripping indentation.
			std::string content = produceOutput(output);
			boost::trim_right(content);
			std::string separator = (content.empty() ? "" : (output == Output::Assembly ? "\n" : " "));
			m_obtainedResult += c_outputLabels.at(output) + ":" + separator + content;
		}

	return checkResult(_stream, _linePrefix, _formatted);
}
