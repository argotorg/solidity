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

#include <test/libsolidity/JSONExpectationTest.h>

#include <libsolidity/interface/DebugSettings.h>

namespace solidity::frontend::test
{
/// Isoltest test case for asserting against the compiler's ethdebug JSON output.
///
/// Settings (in the `// ====` block):
///   - `EVMVersion: <constraint>`        — gates whether the test runs (inherited).
///   - `optimize: <bool>`                — enable optimizer (default: false).
///   - `optimize-yul: <bool>`            — additionally run the Yul optimizer (default: false).
///   - `compileViaSSACFG: <bool>`        — route codegen through the SSA-CFG (default: false).
///   - `revertStrings: default|strip|debug|verboseDebug`
///                                       — revert string behavior (default: default).
///
/// Compilation is always performed with `viaIR=true`, `experimental=true`, ethdebug
/// debug info enabled, and metadata stripped, so the output is stable across builds.
///
/// Scope keys exposed to expectations:
///   - Globals: `.resources`, `.compilation`.
///   - Per contract: `Contract.creation`, `Contract.runtime`, `Contract.contract`.
///   - Source-qualified per contract (when needed to disambiguate same-named
///     contracts in different sources): `source.sol:Contract.creation`, etc.
class EthdebugTest: public JSONExpectationTest
{
public:
	static std::unique_ptr<TestCase> create(Config const& _config)
	{
		return std::make_unique<EthdebugTest>(_config.filename);
	}

	EthdebugTest(std::string const& _filename);

protected:
	void setupCompiler(CompilerStack& _compiler) override;
	PathParts splitPath(std::string_view _path) const override;
	std::optional<Json> fetchOutput(
		std::string_view _qualifiedContract,
		std::string_view _outputName
	) const override;

private:
	std::optional<std::string> resolveContractName(std::string_view _name) const;

	bool m_optimise = false;
	bool m_optimiseYul = false;
	bool m_useSSACFG = false;
	RevertStrings m_revertStrings = RevertStrings::Default;
};

}
