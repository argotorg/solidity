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

#include <test/libsolidity/EthdebugTest.h>
#include <test/Common.h>

#include <liblangutil/DebugInfoSelection.h>

#include <libsolidity/interface/OptimiserSettings.h>

#include <boost/throw_exception.hpp>

#include <algorithm>
#include <stdexcept>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::frontend::test;
using namespace solidity::langutil;
using namespace std::string_literals;

EthdebugTest::EthdebugTest(std::string const& _filename):
	JSONExpectationTest(_filename)
{
	m_optimise = m_reader.boolSetting("optimize", false);
	m_optimiseYul = m_reader.boolSetting("optimize-yul", false);
	m_useSSACFG = m_reader.boolSetting("compileViaSSACFG", false);

	auto const revertStrings = revertStringsFromString(m_reader.stringSetting("revertStrings", "default"));
	if (!revertStrings)
		BOOST_THROW_EXCEPTION(std::runtime_error("Invalid revertStrings setting."));
	m_revertStrings = *revertStrings;
}

void EthdebugTest::setupCompiler(CompilerStack& _compiler)
{
	AnalysisFramework::setupCompiler(_compiler);

	_compiler.setViaIR(true);
	_compiler.setExperimental(true);
	if (m_useSSACFG)
		_compiler.setViaSSACFG(true);

	DebugInfoSelection selection = DebugInfoSelection::Default();
	selection.enable("ethdebug");
	_compiler.selectDebugInfo(selection);

	_compiler.setMetadataFormat(CompilerStack::MetadataFormat::NoMetadata);
	_compiler.setRevertStringBehaviour(m_revertStrings);

	OptimiserSettings settings = m_optimise ? OptimiserSettings::standard() : OptimiserSettings::minimal();
	if (m_optimiseYul)
		settings.runYulOptimiser = true;
	_compiler.setOptimiserSettings(settings);
}

JSONExpectationTest::PathParts EthdebugTest::splitPath(std::string_view _path) const
{
	if (_path.empty())
		BOOST_THROW_EXCEPTION(std::runtime_error("Empty path in expectation"));
	if (_path[0] == ' ' || _path[0] == '\t')
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"Path must not have leading whitespace: "s.append(_path)
		));

	if (_path[0] == '(')
		return JSONExpectationTest::splitPath(_path);

	if (_path[0] == '.')
	{
		auto const secondDot = _path.find('.', 1);
		if (secondDot == std::string_view::npos)
			return {std::string_view{}, _path.substr(1), std::string_view{}};
		return {
			std::string_view{},
			_path.substr(1, secondDot - 1),
			_path.substr(secondDot + 1)
		};
	}

	auto const colonPos = _path.find(':');
	size_t const searchStart = colonPos == std::string_view::npos ? 0 : colonPos + 1;

	auto const outputDot = _path.find('.', searchStart);
	if (outputDot == std::string_view::npos)
		return {_path, std::string_view{}, std::string_view{}};

	auto const pathDot = _path.find('.', outputDot + 1);
	if (pathDot == std::string_view::npos)
		return {
			_path.substr(0, outputDot),
			_path.substr(outputDot + 1),
			std::string_view{}
		};
	return {
		_path.substr(0, outputDot),
		_path.substr(outputDot + 1, pathDot - outputDot - 1),
		_path.substr(pathDot + 1)
	};
}

std::optional<Json> EthdebugTest::fetchOutput(
	std::string_view _qualifiedContract,
	std::string_view _outputName
) const
{
	if (compiler().state() < CompilerStack::State::CompilationSuccessful)
		return std::nullopt;

	if (_qualifiedContract.empty())
	{
		if (_outputName == "compilation")
			return compiler().ethdebugCompilation();
		if (_outputName == "resources")
			return compiler().ethdebug();
		return std::nullopt;
	}

	if (auto const resolved = resolveContractName(_qualifiedContract))
	{
		if (_outputName == "creation")
			return compiler().ethdebug(*resolved);
		if (_outputName == "runtime")
			return compiler().ethdebugRuntime(*resolved);
		if (_outputName == "contract")
		{
			Json const creation = compiler().ethdebug(*resolved);
			if (creation.is_null() || !creation.contains("contract"))
				return std::nullopt;
			return creation["contract"];
		}
	}
	return std::nullopt;
}

std::optional<std::string> EthdebugTest::resolveContractName(std::string_view _name) const
{
	auto const& contractNames = compiler().contractNames();

	auto const isMatch = [&](std::string const& contractName) {
		return contractName == _name || compiler().contractDefinition(contractName).name() == _name;
	};

	if (std::ranges::count_if(contractNames, isMatch) != 1)
		return std::nullopt;
	return *std::ranges::find_if(contractNames, isMatch);
}
