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

ObjectCompilerTest::ObjectCompilerTest(std::string const& _filename):
	solidity::frontend::test::EVMVersionRestrictedTestCase(_filename)
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

	constexpr std::array allowedOutputs = {"Assembly", "Bytecode", "Opcodes", "SourceMappings"};
	boost::split(m_outputSetting, m_reader.stringSetting("outputs", "Assembly,Bytecode,Opcodes,SourceMappings"), boost::is_any_of(","));
	for (auto const& output: m_outputSetting)
		if (std::find(allowedOutputs.begin(), allowedOutputs.end(), output) == allowedOutputs.end())
			BOOST_THROW_EXCEPTION(std::runtime_error{"Invalid output type: \"" + output + "\""});

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

	if (std::find(m_outputSetting.begin(), m_outputSetting.end(), "Assembly") != m_outputSetting.end())
		m_obtainedResult = "Assembly:\n" + obj.assembly->assemblyString(yulStack.debugInfoSelection());
	if (obj.bytecode->bytecode.empty())
		m_obtainedResult += "-- empty bytecode --\n";
	else
	{
		if (std::find(m_outputSetting.begin(), m_outputSetting.end(), "Bytecode") != m_outputSetting.end())
			m_obtainedResult += "Bytecode: " + util::toHex(obj.bytecode->bytecode);
		if (std::find(m_outputSetting.begin(), m_outputSetting.end(), "Opcodes") != m_outputSetting.end())
		{
			m_obtainedResult += (!m_obtainedResult.empty() && m_obtainedResult.back() != '\n') ? "\n" : "";
			m_obtainedResult += "Opcodes: " +
				boost::trim_copy(evmasm::disassemble(obj.bytecode->bytecode, solidity::test::CommonOptions::get().evmVersion()));
		}
		if (std::find(m_outputSetting.begin(), m_outputSetting.end(), "SourceMappings") != m_outputSetting.end())
		{
			m_obtainedResult += (!m_obtainedResult.empty() && m_obtainedResult.back() != '\n') ? "\n" : "";
			m_obtainedResult += "SourceMappings:" + (obj.sourceMappings->empty() ? "" : " " + *obj.sourceMappings) + "\n";
		}
	}

	return checkResult(_stream, _linePrefix, _formatted);
}
