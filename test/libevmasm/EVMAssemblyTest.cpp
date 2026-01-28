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
#include <boost/algorithm/string/split.hpp>
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

std::vector<std::string> const EVMAssemblyTest::c_outputLabels = {
	"InputAssemblyJSON",
	"Assembly",
	"Bytecode",
	"Opcodes",
	"SourceMappings",
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

	if (_filename.ends_with(".asmjson"))
		m_assemblyFormat = AssemblyFormat::JSON;
	else if (_filename.ends_with(".asm"))
		m_assemblyFormat = AssemblyFormat::Plain;
	else
		BOOST_THROW_EXCEPTION(std::runtime_error("Not an assembly test: \"" + _filename + "\". Allowed extensions: .asm, .asmjson."));

	m_selectedOutputs = m_reader.stringSetting("outputs", "Assembly,Bytecode,Opcodes,SourceMappings");
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

	auto const produceOutput = [&](std::string const& _output) {
		if (_output == "InputAssemblyJSON")
			return assemblyJSON;
		if (_output == "Assembly")
			return evmAssemblyStack.assemblyString({{m_reader.fileName().filename().string(), m_source}});
		if (_output == "Bytecode")
			return util::toHex(evmAssemblyStack.object().bytecode);
		if (_output == "Opcodes")
			return disassemble(evmAssemblyStack.object().bytecode, CommonOptions::get().evmVersion());
		if (_output == "SourceMappings")
			return evmAssemblyStack.sourceMapping();
		soltestAssert(false);
		unreachable();
	};

	std::set<std::string> selectedOutputSet;
	boost::split(selectedOutputSet, m_selectedOutputs, boost::is_any_of(","));
	for (std::string const& output: c_outputLabels)
		if (selectedOutputSet.contains(output))
		{
			if (!m_obtainedResult.empty() && m_obtainedResult.back() != '\n')
				m_obtainedResult += "\n";

			// Don't trim on the left to avoid stripping indentation.
			std::string content = produceOutput(output);
			boost::trim_right(content);
			std::string separator = (content.empty() ? "" : (output == "Assembly" ? "\n" : " "));
			m_obtainedResult += output + ":" + separator + content;
		}
	if (!m_obtainedResult.empty() && m_obtainedResult.back() != '\n')
		m_obtainedResult += "\n";

	return checkResult(_stream, _linePrefix, _formatted);
}
