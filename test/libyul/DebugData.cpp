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
/// Tests for Yul debug annotations.

#include <test/Common.h>

#include <liblangutil/DebugInfoSelection.h>
#include <libsolidity/interface/OptimiserSettings.h>
#include <libyul/AST.h>
#include <libyul/Object.h>
#include <libyul/YulStack.h>

#include <boost/test/unit_test.hpp>

#include <memory>
#include <string>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::langutil;
using solidity::test::CommonOptions;

namespace solidity::yul::test
{

namespace
{

FunctionDefinition const* findFunctionDefinition(Block const& _block)
{
	for (Statement const& statement: _block.statements)
		if (auto const* functionDefinition = std::get_if<FunctionDefinition>(&statement);
			functionDefinition != nullptr
		)
			return functionDefinition;
	return nullptr;
}

OptimiserSettings noOptimization()
{
	OptimiserSettings settings = OptimiserSettings::none();
	settings.yulOptimiserSteps = "";
	settings.yulOptimiserCleanupSteps = "";
	return settings;
}

}

BOOST_AUTO_TEST_SUITE(YulDebugDataTest)

BOOST_AUTO_TEST_CASE(ast_id_instance_annotation_round_trips)
{
	YulStack yulStack(
		CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	// A cloned scope carries its instance next to the origin. An instance
	// without an accompanying @ast-id on the same node is ignored.
	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	{
		/** @ast-id 23 @ast-id-instance 2 */
		function f() {
			let var_x := 1
			pop(var_x)
		}
		/** @ast-id-instance 5 */
		function g() {}
		f()
		g()
	})"));

	auto const* funDef = findFunctionDefinition(yulStack.parserResult()->code()->root());
	BOOST_REQUIRE(funDef);
	BOOST_REQUIRE(funDef->debugData->astID.has_value());
	BOOST_CHECK_EQUAL(*funDef->debugData->astID, 23);
	BOOST_REQUIRE(funDef->debugData->astIDInstance.has_value());
	BOOST_CHECK_EQUAL(*funDef->debugData->astIDInstance, 2);
	FunctionDefinition const* ignored = nullptr;
	for (Statement const& statement: yulStack.parserResult()->code()->root().statements)
		if (auto const* definition = std::get_if<FunctionDefinition>(&statement);
			definition != nullptr
		)
			if (definition->name.str() == "g")
				ignored = definition;
	BOOST_REQUIRE(ignored);
	BOOST_CHECK(!ignored->debugData->astID.has_value());
	BOOST_CHECK(!ignored->debugData->astIDInstance.has_value());

	// The annotation survives printing and reparsing.
	std::string const printed = yulStack.print();
	BOOST_CHECK(printed.find("@ast-id 23 @ast-id-instance 2") != std::string::npos);
	yulStack.optimize();
	auto const* reparsedFunDef = findFunctionDefinition(yulStack.parserResult()->code()->root());
	BOOST_REQUIRE(reparsedFunDef);
	BOOST_REQUIRE(reparsedFunDef->debugData->astIDInstance.has_value());
	BOOST_CHECK_EQUAL(*reparsedFunDef->debugData->astIDInstance, 2);
}

BOOST_AUTO_TEST_SUITE_END()

} // namespace solidity::yul::test
