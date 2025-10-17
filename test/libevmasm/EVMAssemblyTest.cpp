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

#include <test/libevmasm/EVMAssemblyTest.h>

#include <test/libevmasm/PlainAssemblyParser.h>

#include <test/Common.h>

#include <libevmasm/Disassemble.h>
#include <libevmasm/EVMAssemblyStack.h>

#include <boost/algorithm/string/predicate.hpp>
#include <boost/algorithm/string/trim.hpp>

#include <range/v3/view/map.hpp>

using namespace std::string_literals;
using namespace solidity;
using namespace solidity::test;
using namespace solidity::evmasm;
using namespace solidity::evmasm::test;
using namespace solidity::frontend;
using namespace solidity::frontend::test;
using namespace solidity::langutil;
using namespace solidity::util;

std::map<EVMAssemblyTest::Output, std::string> const EVMAssemblyTest::c_outputLabels = {
	{EVMAssemblyTest::Output::InputAssemblyJSON, "InputAssemblyJSON"},
	{EVMAssemblyTest::Output::Assembly, "Assembly"},
	{EVMAssemblyTest::Output::Bytecode, "Bytecode"},
	{EVMAssemblyTest::Output::Opcodes, "Opcodes"},
	{EVMAssemblyTest::Output::SourceMappings, "SourceMappings"},
};

std::unique_ptr<TestCase> EVMAssemblyTest::create(Config const& _config)
{
	return std::make_unique<EVMAssemblyTest>(_config.filename);
}

EVMAssemblyTest::EVMAssemblyTest(std::string const& _filename):
	EVMVersionRestrictedTestCase(_filename)
{
	m_source = m_reader.source();
	m_expectation = m_reader.simpleExpectations();

	if (boost::algorithm::ends_with(_filename, ".asmjson"))
		m_assemblyFormat = AssemblyFormat::JSON;
	else if (boost::algorithm::ends_with(_filename, ".asm"))
		m_assemblyFormat = AssemblyFormat::Plain;
	else
		solThrow(ValidationError, "Not an assembly test: \"" + _filename + "\". Allowed extensions: .asm, .asmjson.");

	m_selectedOutputs = m_reader.enumSetSetting(
		"outputs",
		c_outputLabels,
		{Output::Assembly, Output::Bytecode, Output::Opcodes, Output::SourceMappings}
	);
	OptimisationPreset optimizationPreset = m_reader.enumSetting<OptimisationPreset>(
		"optimizationPreset",
		{
			{"none", OptimisationPreset::None},
			{"minimal", OptimisationPreset::Minimal},
			{"standard", OptimisationPreset::Standard},
			{"full", OptimisationPreset::Full},
		},
		"none"
	);
	m_optimizerSettings = Assembly::OptimiserSettings::translateSettings(OptimiserSettings::preset(optimizationPreset));
	m_optimizerSettings.expectedExecutionsPerDeployment = m_reader.sizetSetting(
		"optimizer.expectedExecutionsPerDeployment",
		m_optimizerSettings.expectedExecutionsPerDeployment
	);

	auto const optimizerComponentSetting = [&](std::string const& _component, bool& _setting) {
		_setting = m_reader.boolSetting("optimizer." + _component, _setting);
	};
	optimizerComponentSetting("inliner", m_optimizerSettings.runInliner);
	optimizerComponentSetting("jumpdestRemover", m_optimizerSettings.runJumpdestRemover);
	optimizerComponentSetting("peephole", m_optimizerSettings.runPeephole);
	optimizerComponentSetting("deduplicate", m_optimizerSettings.runDeduplicate);
	optimizerComponentSetting("cse", m_optimizerSettings.runCSE);
	optimizerComponentSetting("constantOptimizer", m_optimizerSettings.runConstantOptimiser);

	// TODO: Enable when assembly import for EOF is implemented.
	if (CommonOptions::get().eofVersion().has_value())
		m_shouldRun = false;
}

TestCase::TestResult EVMAssemblyTest::run(std::ostream& _stream, std::string const& _linePrefix, bool const _formatted)
{
	EVMAssemblyStack evmAssemblyStack(
		CommonOptions::get().evmVersion(),
		CommonOptions::get().eofVersion(),
		m_optimizerSettings
	);

	evmAssemblyStack.selectDebugInfo(DebugInfoSelection::AllExceptExperimental());

	std::string assemblyJSON;
	switch (m_assemblyFormat)
	{
	case AssemblyFormat::JSON:
		assemblyJSON = m_source;
		break;
	case AssemblyFormat::Plain:
		assemblyJSON = jsonPrint(
			PlainAssemblyParser{}.parse(m_reader.fileName().filename().string(), m_source),
			{JsonFormat::Pretty, 4}
		);
		break;
	}

	try
	{
		evmAssemblyStack.parseAndAnalyze(m_reader.fileName().filename().string(), assemblyJSON);
	}
	catch (AssemblyImportException const& _exception)
	{
		m_obtainedResult = "AssemblyImportException: "s + _exception.what() + "\n";
		return checkResult(_stream, _linePrefix, _formatted);
	}

	try
	{
		evmAssemblyStack.assemble();
	}
	catch (Error const& _error)
	{
		// TODO: EVMAssemblyStack should catch these on its own and provide an error reporter.
		soltestAssert(_error.comment(), "Errors must include a message for the user.");
		m_obtainedResult = Error::formatErrorType(_error.type()) + ": " + *_error.comment() + "\n";
		return checkResult(_stream, _linePrefix, _formatted);
	}
	soltestAssert(evmAssemblyStack.compilationSuccessful());

	auto const produceOutput = [&](Output _output) {
		switch (_output)
		{
		case Output::InputAssemblyJSON: return assemblyJSON;
		case Output::Assembly: return evmAssemblyStack.assemblyString({{m_reader.fileName().filename().string(), m_source}});
		case Output::Bytecode: return util::toHex(evmAssemblyStack.object().bytecode);
		case Output::Opcodes: return disassemble(evmAssemblyStack.object().bytecode, CommonOptions::get().evmVersion());
		case Output::SourceMappings: return evmAssemblyStack.sourceMapping();
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
