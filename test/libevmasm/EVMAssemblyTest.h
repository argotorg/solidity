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

#include <libevmasm/Assembly.h>

#include <memory>
#include <ostream>
#include <string>
#include <vector>

namespace solidity::evmasm::test
{

/// Custom test case that runs the final part of the compiler pipeline (assembling into bytecode).
/// Supports two kinds of input (depending on file extension):
/// - .asmjson: assembly JSON format produced by --asm-json.
/// - .asm: plain assembly, a more limited but human-readable format that is internally converted
///     to assembly JSON.
///
/// Available settings:
/// - EVMVersion: The range of EVM versions to run the test for. Inherited from EVMVersionRestrictedTestCase.
/// - bytecodeFormat: The range of bytecode formats (EOF/legacy) to run the test for. Inherited from EVMVersionRestrictedTestCase.
/// - outputs: List of outputs to include in the test. The order of values does NOT determine the order
///     in which the outputs are printed. Supported outputs: InputAssemblyJSON, Assembly, Bytecode, Opcodes, SourceMappings.
///     The default is to print all outputs except InputAssemblyJSON.
/// - optimizationPreset: Preset to load as the base optimizer settings.
///     One of: none, minimal, standard, full. The default is none.
/// - optimizer.*: A set of detailed optimizer settings applied on top of the base preset.
///     Each one corresponds to a field in Assembly::OptimiserSettings and uses the value from the
///     preset as its default. Available settings:
///     - optimizer.expectedExecutionsPerDeployment (integer)
///     - optimizer.inliner (bool)
///     - optimizer.jumpdestRemover (bool)
///     - optimizer.peephole (bool)
///     - optimizer.deduplicate (bool)
///     - optimizer.cse (bool)
///     - optimizer.constantOptimizer (bool)
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

	static std::vector<std::string> const c_outputLabels;

	AssemblyFormat m_assemblyFormat{};
	std::string m_selectedOutputs;
	evmasm::Assembly::OptimiserSettings m_optimizerSettings;
};

}
