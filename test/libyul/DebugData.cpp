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
 * Unit tests for the transfer of semantic debug info between the side table
 * and Yul AST nodes across reparsing.
 */

#include <test/Common.h>

#include <liblangutil/DebugInfoSelection.h>
#include <liblangutil/SemanticDebugData.h>
#include <liblangutil/SemanticDebugDataTable.h>
#include <libsolidity/interface/OptimiserSettings.h>
#include <libyul/AST.h>
#include <libyul/Object.h>
#include <libyul/YulStack.h>

#include <boost/test/unit_test.hpp>

#include <memory>
#include <string>
#include <vector>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::langutil;

namespace solidity::yul::test
{

namespace
{

FunctionDefinition* findFunctionDefinition(Block& _block)
{
	for (Statement& statement: _block.statements)
		if (auto* functionDefinition = std::get_if<FunctionDefinition>(&statement))
			return functionDefinition;
	return nullptr;
}

FunctionDefinition const* findFunctionDefinition(Block const& _block)
{
	for (Statement const& statement: _block.statements)
		if (auto const* functionDefinition = std::get_if<FunctionDefinition>(&statement))
			return functionDefinition;
	return nullptr;
}

/// A stack region reading the Yul local @a _name, as the producer emits it.
SemanticDebugPointer stackPointer(std::string _name)
{
	return SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Stack,
		_name,
		SemanticDebugPointerExpression::yulLocal(std::move(_name))
	);
}

/// Settings that reparse without optimizing, so that only the transfer is tested.
OptimiserSettings noOptimization()
{
	OptimiserSettings settings = OptimiserSettings::none();
	settings.yulOptimiserSteps = "";
	settings.yulOptimiserCleanupSteps = "";
	return settings;
}

SemanticDebugDataTable stackVariableTable(int64_t _astID, std::string _name, std::string _slot)
{
	SemanticDebugVariable variable;
	variable.identifier = std::move(_name);
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = stackPointer(std::move(_slot));

	SemanticDebugScope data;
	data.variableDefinitions.emplace_back(std::move(variable));

	SemanticDebugDataTable table;
	table.set(_astID, std::make_shared<SemanticDebugScope const>(std::move(data)));
	return table;
}

void checkStackVariableSurvived(FunctionDefinition const& _function)
{
	BOOST_REQUIRE(_function.debugData);
	BOOST_REQUIRE(_function.debugData->semanticDebugScope);
	SemanticDebugScope const& data = *_function.debugData->semanticDebugScope;
	BOOST_REQUIRE_EQUAL(data.variableDefinitions.size(), 1);
	SemanticDebugVariable const& variable = data.variableDefinitions.front();
	BOOST_CHECK(variable.phase == SemanticDebugVariablePhase::Materialized);
	BOOST_REQUIRE(variable.pointer);
}

void checkStackVariableOptimizedOut(FunctionDefinition const& _function)
{
	BOOST_REQUIRE(_function.debugData);
	BOOST_REQUIRE(_function.debugData->semanticDebugScope);
	SemanticDebugScope const& data = *_function.debugData->semanticDebugScope;
	BOOST_REQUIRE_EQUAL(data.variableDefinitions.size(), 1);
	SemanticDebugVariable const& variable = data.variableDefinitions.front();
	BOOST_CHECK(variable.phase == SemanticDebugVariablePhase::OptimizedOut);
	BOOST_CHECK(!variable.pointer);
}

}

BOOST_AUTO_TEST_SUITE(YulDebugDataTest)

BOOST_AUTO_TEST_CASE(semantic_debug_data_survives_reparse_by_ast_id)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	{
		/** @ast-id 23 */
		function f() {
			pop(1)
		}
	})"));

	auto const object = yulStack.parserResult();
	auto& root = const_cast<Block&>(object->code()->root());
	auto* funDef = findFunctionDefinition(root);
	BOOST_REQUIRE(funDef);
	BOOST_REQUIRE(funDef->debugData);
	BOOST_REQUIRE(funDef->debugData->astID);
	BOOST_REQUIRE_EQUAL(*funDef->debugData->astID, 23);

	SemanticDebugScope data;
	auto semanticDebugData = std::make_shared<SemanticDebugScope const>(std::move(data));
	funDef->debugData = DebugData::create(
		funDef->debugData->nativeLocation,
		funDef->debugData->originLocation,
		funDef->debugData->astID,
		funDef->debugData->astIDInstance,
		semanticDebugData
	);

	yulStack.optimize();

	auto const& reparsedRoot = yulStack.parserResult()->code()->root();
	auto const* reparsedFunDef = findFunctionDefinition(reparsedRoot);
	BOOST_REQUIRE(reparsedFunDef);
	BOOST_REQUIRE(reparsedFunDef->debugData);
	BOOST_REQUIRE(reparsedFunDef->debugData->astID);
	BOOST_CHECK_EQUAL(*reparsedFunDef->debugData->astID, 23);
	BOOST_REQUIRE(reparsedFunDef->debugData->semanticDebugScope);
	BOOST_CHECK(reparsedFunDef->debugData->semanticDebugScope == semanticDebugData);
}

BOOST_AUTO_TEST_CASE(reparse_marks_missing_stack_locations_optimized_out)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	{
		/** @ast-id 23 */
		function f() {
			pop(1)
		}
	})"));

	auto const object = yulStack.parserResult();
	auto& root = const_cast<Block&>(object->code()->root());
	auto* funDef = findFunctionDefinition(root);
	BOOST_REQUIRE(funDef);
	BOOST_REQUIRE(funDef->debugData);
	BOOST_REQUIRE(funDef->debugData->astID);

	SemanticDebugVariable variable;
	variable.identifier = "value";
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = stackPointer("missing_slot");

	SemanticDebugScope data;
	data.variableDefinitions.emplace_back(std::move(variable));
	auto semanticDebugData = std::make_shared<SemanticDebugScope const>(std::move(data));
	funDef->debugData = DebugData::create(
		funDef->debugData->nativeLocation,
		funDef->debugData->originLocation,
		funDef->debugData->astID,
		funDef->debugData->astIDInstance,
		semanticDebugData
	);

	yulStack.optimize();

	auto const& reparsedRoot = yulStack.parserResult()->code()->root();
	auto const* reparsedFunDef = findFunctionDefinition(reparsedRoot);
	BOOST_REQUIRE(reparsedFunDef);
	BOOST_REQUIRE(reparsedFunDef->debugData);
	BOOST_REQUIRE(reparsedFunDef->debugData->semanticDebugScope);
	BOOST_CHECK(reparsedFunDef->debugData->semanticDebugScope != semanticDebugData);

	SemanticDebugScope const& reparsedDebugData = *reparsedFunDef->debugData->semanticDebugScope;
	BOOST_REQUIRE_EQUAL(reparsedDebugData.variableDefinitions.size(), 1);
	SemanticDebugVariable const& reparsedVariable = reparsedDebugData.variableDefinitions.front();
	BOOST_CHECK(reparsedVariable.phase == SemanticDebugVariablePhase::OptimizedOut);
	BOOST_CHECK(!reparsedVariable.pointer);
}

BOOST_AUTO_TEST_CASE(attach_marks_missing_stack_locations_optimized_out)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	{
		/** @ast-id 23 */
		function f() {
			pop(1)
		}
	})"));

	// No optimization or reparse involved: attaching to IR whose stack slots are
	// already gone must mark the variable OptimizedOut right away.
	yulStack.attachSemanticDebugData(stackVariableTable(23, "value", "missing_slot"));

	auto const* funDef = findFunctionDefinition(yulStack.parserResult()->code()->root());
	BOOST_REQUIRE(funDef);
	checkStackVariableOptimizedOut(*funDef);
}

BOOST_AUTO_TEST_CASE(bound_pointer_variables_do_not_affect_survival)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	{
		/** @ast-id 23 */
		function f() {
			let var_x := 1
			pop(var_x)
		}
		f()
	})"));

	// The pointer references var_x (a Yul variable that exists), "aux" (bound by
	// a scope definition), "item" (bound as a list index) and "key" (bound as a
	// template parameter). Only var_x is a free Yul dependency, so the stack
	// location must survive.
	SemanticDebugPointer element = SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Stack,
		"element",
		SemanticDebugPointerExpression::sum({
			SemanticDebugPointerExpression::variable("var_x"),
			SemanticDebugPointerExpression::variable("aux"),
			SemanticDebugPointerExpression::variable("item"),
			SemanticDebugPointerExpression::variable("key")
		})
	);
	SemanticDebugPointer pointer = SemanticDebugPointer::scope(
		{{"aux", SemanticDebugPointerExpression::literal("0x01")}},
		SemanticDebugPointer::list(
			SemanticDebugPointerExpression::literal("0x02"),
			"item",
			std::move(element)
		)
	);
	pointer.expectedParameters = {"key"};

	SemanticDebugVariable variable;
	variable.identifier = "x";
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = std::move(pointer);

	SemanticDebugScope data;
	data.variableDefinitions.emplace_back(std::move(variable));

	SemanticDebugDataTable table;
	table.set(23, std::make_shared<SemanticDebugScope const>(std::move(data)));
	yulStack.attachSemanticDebugData(table);

	auto const* funDef = findFunctionDefinition(yulStack.parserResult()->code()->root());
	BOOST_REQUIRE(funDef);
	checkStackVariableSurvived(*funDef);
}

BOOST_AUTO_TEST_CASE(free_pointer_variables_in_expressions_require_yul_names)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	{
		/** @ast-id 23 */
		function f() {
			let var_x := 1
			pop(var_x)
		}
		f()
	})"));

	// The slot expression references a Yul variable that does not exist even
	// though it is buried inside arithmetic; the location must be dropped.
	SemanticDebugPointer pointer = SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Stack,
		"element",
		SemanticDebugPointerExpression::sum({
			SemanticDebugPointerExpression::variable("var_x"),
			SemanticDebugPointerExpression::variable("var_missing")
		})
	);

	SemanticDebugVariable variable;
	variable.identifier = "x";
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = std::move(pointer);

	SemanticDebugScope data;
	data.variableDefinitions.emplace_back(std::move(variable));

	SemanticDebugDataTable table;
	table.set(23, std::make_shared<SemanticDebugScope const>(std::move(data)));
	yulStack.attachSemanticDebugData(table);

	auto const* funDef = findFunctionDefinition(yulStack.parserResult()->code()->root());
	BOOST_REQUIRE(funDef);
	checkStackVariableOptimizedOut(*funDef);
}

BOOST_AUTO_TEST_CASE(stack_location_survival_is_scoped_per_object)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	object "a" {
		code {
			/** @ast-id 23 */
			function f() {
				let var_x := 1
				pop(var_x)
			}
			f()
		}
		/// @use-src 0:"source"
		object "a_deployed" {
			code {
				/** @ast-id 23 */
				function f() {
					pop(1)
				}
				f()
			}
		}
	})"));

	yulStack.attachSemanticDebugData(stackVariableTable(23, "x", "var_x"));

	auto const object = yulStack.parserResult();
	auto const* creationFunDef = findFunctionDefinition(object->code()->root());
	BOOST_REQUIRE(creationFunDef);
	checkStackVariableSurvived(*creationFunDef);

	BOOST_REQUIRE_EQUAL(object->subObjects.size(), 1);
	auto const* deployedObject = dynamic_cast<Object const*>(object->subObjects.front().get());
	BOOST_REQUIRE(deployedObject);
	auto const* deployedFunDef = findFunctionDefinition(deployedObject->code()->root());
	BOOST_REQUIRE(deployedFunDef);
	// The slot only survives in the creation code, so the deployed code must not
	// report a stale stack location for it.
	checkStackVariableOptimizedOut(*deployedFunDef);
}

BOOST_AUTO_TEST_CASE(template_references_resolve_through_the_table)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	{
		/** @ast-id 23 */
		function f() {
			pop(1)
		}
	})"));

	// The variable's pointer is a reference to a storage template in the
	// table. Storage templates read no Yul names, so the reference survives
	// even though the function declares no variables at all.
	SemanticDebugVariable variable;
	variable.identifier = "stored";
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = SemanticDebugPointer::templateReference("storage_1_2");

	SemanticDebugScope data;
	data.variableDefinitions.emplace_back(std::move(variable));

	SemanticDebugDataTable table;
	table.setPointerTemplate("storage_1_2", SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Storage,
		"stored",
		SemanticDebugPointerExpression::literal("0x02")));
	table.set(23, std::make_shared<SemanticDebugScope const>(std::move(data)));
	yulStack.attachSemanticDebugData(table);

	auto const* funDef = findFunctionDefinition(yulStack.parserResult()->code()->root());
	BOOST_REQUIRE(funDef);
	checkStackVariableSurvived(*funDef);
	BOOST_REQUIRE(yulStack.semanticDebugData().findPointerTemplate("storage_1_2"));

	// A reference whose template reads a missing Yul name is invalidated
	// like a direct pointer would be.
	SemanticDebugDataTable stackTable;
	SemanticDebugVariable referencing;
	referencing.identifier = "value";
	referencing.phase = SemanticDebugVariablePhase::Materialized;
	referencing.pointer = SemanticDebugPointer::templateReference("stack-template");
	SemanticDebugScope referencingScope;
	referencingScope.variableDefinitions.emplace_back(std::move(referencing));
	stackTable.setPointerTemplate("stack-template", stackPointer("missing_slot"));
	stackTable.set(23, std::make_shared<SemanticDebugScope const>(std::move(referencingScope)));
	yulStack.attachSemanticDebugData(stackTable);
	checkStackVariableOptimizedOut(*funDef);
}

BOOST_AUTO_TEST_CASE(ast_id_instance_annotation_round_trips)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
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
	BOOST_REQUIRE(funDef->debugData->astID);
	BOOST_CHECK_EQUAL(*funDef->debugData->astID, 23);
	BOOST_REQUIRE(funDef->debugData->astIDInstance);
	BOOST_CHECK_EQUAL(*funDef->debugData->astIDInstance, 2);
	FunctionDefinition const* ignored = nullptr;
	for (Statement const& statement: yulStack.parserResult()->code()->root().statements)
		if (auto const* definition = std::get_if<FunctionDefinition>(&statement))
			if (definition->name.str() == "g")
				ignored = definition;
	BOOST_REQUIRE(ignored);
	BOOST_CHECK(!ignored->debugData->astID);
	BOOST_CHECK(!ignored->debugData->astIDInstance);

	// The table keys the record by (astID, instance); instance 0 does not match.
	SemanticDebugDataTable table;
	SemanticDebugScope clonedScope;
	SemanticDebugVariable variable;
	variable.identifier = "x";
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = stackPointer("var_x");
	clonedScope.variableDefinitions.emplace_back(std::move(variable));
	table.set({23, 2}, std::make_shared<SemanticDebugScope const>(std::move(clonedScope)));
	table.set({23, 0}, std::make_shared<SemanticDebugScope const>());
	yulStack.attachSemanticDebugData(table);
	checkStackVariableSurvived(*funDef);

	// The annotation survives printing and reparsing, and so does the record.
	std::string const printed = yulStack.print();
	BOOST_CHECK(printed.find("@ast-id 23 @ast-id-instance 2") != std::string::npos);
	yulStack.optimize();
	auto const* reparsedFunDef = findFunctionDefinition(yulStack.parserResult()->code()->root());
	BOOST_REQUIRE(reparsedFunDef);
	BOOST_REQUIRE(reparsedFunDef->debugData->astIDInstance);
	BOOST_CHECK_EQUAL(*reparsedFunDef->debugData->astIDInstance, 2);
	checkStackVariableSurvived(*reparsedFunDef);
}

BOOST_AUTO_TEST_CASE(contract_scope_attaches_to_the_top_level_block)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	// Contract-level variables have no Yul node of their own; their record
	// attaches to the object's top-level block, which carries the contract's
	// AST ID the way the IR generator emits it.
	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	object "C" {
		code /** @ast-id 7 */ {
			sstore(0, 1)
		}
	})"));

	SemanticDebugVariable stored;
	stored.identifier = "stored";
	stored.phase = SemanticDebugVariablePhase::Materialized;
	stored.pointer = SemanticDebugPointer::templateReference("storage_7_3");
	SemanticDebugScope contractScope;
	contractScope.variableDefinitions.emplace_back(std::move(stored));
	SemanticDebugDataTable table;
	table.setPointerTemplate("storage_7_3", SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Storage,
		"stored",
		SemanticDebugPointerExpression::literal("0x00")));
	table.set(7, std::make_shared<SemanticDebugScope const>(std::move(contractScope)));
	yulStack.attachSemanticDebugData(table);

	Block const& root = yulStack.parserResult()->code()->root();
	BOOST_REQUIRE(root.debugData);
	BOOST_REQUIRE(root.debugData->astID);
	BOOST_CHECK_EQUAL(*root.debugData->astID, 7);
	BOOST_REQUIRE(root.debugData->semanticDebugScope);
	BOOST_REQUIRE_EQUAL(root.debugData->semanticDebugScope->variableDefinitions.size(), 1);
	BOOST_CHECK(root.debugData->semanticDebugScope->variableDefinitions.front().phase == SemanticDebugVariablePhase::Materialized);

	// The block's annotation is printed before the block, so the attachment
	// survives a reparse.
	std::string const printed = yulStack.print();
	size_t const code = printed.find("code");
	size_t const annotation = printed.find("@ast-id 7");
	BOOST_REQUIRE(code != std::string::npos && annotation != std::string::npos);
	BOOST_CHECK(code < annotation && annotation < printed.find('{', code));
	yulStack.optimize();
	Block const& reparsedRoot = yulStack.parserResult()->code()->root();
	BOOST_REQUIRE(reparsedRoot.debugData && reparsedRoot.debugData->semanticDebugScope);
	BOOST_REQUIRE_EQUAL(reparsedRoot.debugData->semanticDebugScope->variableDefinitions.size(), 1);
}

BOOST_AUTO_TEST_CASE(attach_invalidates_variable_updates_reading_missing_locals)
{
	YulStack yulStack(
		solidity::test::CommonOptions::get().evmVersion(),
		noOptimization(),
		DebugInfoSelection::All()
	);

	BOOST_REQUIRE(yulStack.parseAndAnalyze("source", R"(/// @use-src 0:"source"
	{
		/** @ast-id 23 */
		function f(var_x) {
			pop(var_x)
		}
	})"));

	SemanticDebugVariableUpdate survivingUpdate;
	survivingUpdate.variableASTID = 5;
	survivingUpdate.phase = SemanticDebugVariablePhase::Materialized;
	survivingUpdate.pointer = stackPointer("var_x");
	SemanticDebugVariableUpdate lostUpdate;
	lostUpdate.variableASTID = 6;
	lostUpdate.phase = SemanticDebugVariablePhase::Materialized;
	lostUpdate.pointer = stackPointer("missing_slot");

	SemanticDebugScope scope;
	scope.variableUpdates.emplace_back(std::move(survivingUpdate));
	scope.variableUpdates.emplace_back(std::move(lostUpdate));
	SemanticDebugDataTable table;
	table.set(23, std::make_shared<SemanticDebugScope const>(std::move(scope)));
	yulStack.attachSemanticDebugData(table);

	// Updates are checked like definitions: the one reading a local that no
	// longer exists becomes optimized-out, both on the node and in the table.
	auto checkUpdates = [](SemanticDebugScope const& _scope) {
		BOOST_REQUIRE_EQUAL(_scope.variableUpdates.size(), 2);
		BOOST_CHECK(_scope.variableUpdates[0].phase == SemanticDebugVariablePhase::Materialized);
		BOOST_CHECK(_scope.variableUpdates[0].pointer);
		BOOST_CHECK(_scope.variableUpdates[1].phase == SemanticDebugVariablePhase::OptimizedOut);
		BOOST_CHECK(!_scope.variableUpdates[1].pointer);
	};
	auto const* funDef = findFunctionDefinition(yulStack.parserResult()->code()->root());
	BOOST_REQUIRE(funDef && funDef->debugData && funDef->debugData->semanticDebugScope);
	checkUpdates(*funDef->debugData->semanticDebugScope);
	auto const tableScope = yulStack.semanticDebugData().find(23);
	BOOST_REQUIRE(tableScope);
	checkUpdates(*tableScope);
}

BOOST_AUTO_TEST_SUITE_END()

} // namespace solidity::yul::test
