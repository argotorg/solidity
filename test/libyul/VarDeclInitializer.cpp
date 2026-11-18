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
/**
 * Unit tests for the Yul variable declaration initializer.
 */

#include <test/Common.h>
#include <test/libyul/Common.h>

#include <libyul/AST.h>
#include <libyul/AsmPrinter.h>
#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/optimiser/NameDispenser.h>
#include <libyul/optimiser/OptimiserStep.h>
#include <libyul/optimiser/VarDeclInitializer.h>

#include <liblangutil/DebugData.h>
#include <liblangutil/DebugInfoSelection.h>
#include <liblangutil/SourceLocation.h>

#include <boost/test/unit_test.hpp>

#include <memory>
#include <set>
#include <string>
#include <variant>

using namespace solidity;
using namespace solidity::langutil;
using namespace solidity::yul;
using namespace solidity::yul::test;

BOOST_AUTO_TEST_SUITE(YulVarDeclInitializer)

BOOST_AUTO_TEST_CASE(split_declarations_preserve_debug_data)
{
	Block block = disambiguate("{ let x, y, z }");
	VariableDeclaration& original = std::get<VariableDeclaration>(block.statements.front());
	auto sourceName = std::make_shared<std::string const>("test.sol");
	original.debugData = DebugData::create(
		original.debugData->nativeLocation,
		SourceLocation{10, 20, sourceName},
		42
	);
	DebugData::ConstPtr const debugData = original.debugData;

	EVMDialect const& dialect = EVMDialect::strictAssemblyForEVM(
		solidity::test::CommonOptions::get().evmVersion()
	);
	NameDispenser dispenser(dialect, block);
	std::set<YulName> reserved;
	OptimiserStepContext context{dialect, dispenser, reserved, 0};
	VarDeclInitializer::run(context, block);

	BOOST_REQUIRE_EQUAL(block.statements.size(), 3);
	DebugInfoSelection debugInfo;
	debugInfo.astID = true;
	for (Statement const& statement: block.statements)
	{
		BOOST_REQUIRE(std::holds_alternative<VariableDeclaration>(statement));
		VariableDeclaration const& declaration = std::get<VariableDeclaration>(statement);
		BOOST_CHECK(declaration.debugData == debugData);
		AsmPrinter printer(dialect, {}, debugInfo);
		BOOST_CHECK_EQUAL(
			printer(declaration),
			"/// @ast-id 42\nlet " + declaration.variables.at(0).name.str() + " := 0"
		);
	}
}

BOOST_AUTO_TEST_SUITE_END()
