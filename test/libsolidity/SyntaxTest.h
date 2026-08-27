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

#pragma once

#include <test/CommonSyntaxTest.h>
#include <test/TestCase.h>
#include <test/TestCaseReader.h>
#include <test/libsolidity/AnalysisFramework.h>

#include <liblangutil/EVMVersion.h>
#include <liblangutil/Exceptions.h>

#include <libsolutil/AnsiColorized.h>

#include <string>

namespace solidity::frontend::test
{

using solidity::test::CompilerInput;
using solidity::test::SyntaxTestError;

/**
 * Reflects `compileViaYul` setting, with possible values: `true`, `false` and `also` (default).
 */
enum class CompileViaYul
{
	True,
	False,
	Also
};

/**
 * Settings that reflect what is configured in each test file.
 *
 * Available settings:
 *
 * - stopAfter: `parsing`, `analysis`, or `compilation` (default: `compilation`).
 * - experimental: `true` or `false`. When not set, experimental mode is enabled
 *   automatically when needed.
 * - compileViaYul: `true`, `false`, or `also` (default: `also`).
 *   `true` runs the Yul pipeline only, `false` runs the legacy pipeline only,
 *   `also` runs both.
 * - optimize-yul: `true` or `false` (default: `true`).
 */
struct SyntaxTestSettings
{
	/// Reads and validates each setting from the given test case reader.
	static SyntaxTestSettings fromReader(TestCaseReader& _reader);

	PipelineStage stopAfter = PipelineStage::Compilation;
	bool experimental = false;

	CompileViaYul compileViaYul = CompileViaYul::False;
	bool optimizeYul = false;
};

class SyntaxTest: public AnalysisFramework, public solidity::test::CommonSyntaxTest
{
public:
	SyntaxTest(
		std::string const& _filename,
		langutil::EVMVersion _evmVersion,
		langutil::Error::Severity _minSeverity = langutil::Error::Severity::Info
	):
		CommonSyntaxTest(_filename, _evmVersion),
		m_minSeverity(_minSeverity),
		m_settings(SyntaxTestSettings::fromReader(m_reader))
	{}

	static std::unique_ptr<TestCase> create(Config const& _config)
	{
		return std::make_unique<SyntaxTest>(_config.filename, _config.evmVersion);
	}

protected:
	void setupCompiler(CompilerStack& _compiler) override;
	void parseAndAnalyze() override;

	TestCase::TestResult run(
		std::ostream& _stream,
		std::string const& _linePrefix,
		bool _formatted
	) override;

	/// Filters out all errors with a severity below `m_minSeverity`.
	virtual void filterObtainedErrors();

	/// Throws if an internal compiler error was encountered during code generation.
	void reportUnexpectedErrors();

	langutil::Error::Severity m_minSeverity{};
	SyntaxTestSettings m_settings;
};

}
