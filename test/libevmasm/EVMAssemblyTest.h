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

#include <test/TestCase.h>

#include <libsolidity/interface/OptimiserSettings.h>

#include <libevmasm/Assembly.h>

#include <map>
#include <memory>
#include <ostream>
#include <set>
#include <string>

namespace solidity::evmasm::test
{

class EVMAssemblyTest: public frontend::test::EVMVersionRestrictedTestCase
{
public:
	static std::unique_ptr<TestCase> create(Config const& _config);

	EVMAssemblyTest(std::string const& _filename);

	TestResult run(std::ostream& _stream, std::string const& _linePrefix = "", bool const _formatted = false) override;

private:
	enum class AssemblyFormat
	{
		JSON,
		Plain,
	};

	enum class Output
	{
		InputAssemblyJSON,
		Assembly,
		Bytecode,
		Opcodes,
		SourceMappings,
	};

	static std::map<Output, std::string> const c_outputLabels;

	AssemblyFormat m_assemblyFormat{};
	std::set<Output> m_selectedOutputs;
	evmasm::Assembly::OptimiserSettings m_optimizerSettings;
};

}
