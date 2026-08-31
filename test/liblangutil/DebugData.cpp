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

#include <liblangutil/SemanticDebugDataAnalysis.h>
#include <liblangutil/SemanticDebugDataSerialization.h>
#include <liblangutil/SemanticDebugDataTable.h>

#include <boost/test/unit_test.hpp>

#include <memory>
#include <optional>
#include <set>
#include <string>

namespace solidity::langutil::test
{

namespace
{

SemanticDebugPointer storageRegion(std::string _name, std::string _slot)
{
	return SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Storage,
		std::move(_name),
		SemanticDebugPointerExpression::literal(std::move(_slot))
	);
}

}

BOOST_AUTO_TEST_SUITE(DebugDataTest)

BOOST_AUTO_TEST_CASE(pointer_expressions_compose)
{
	// keccak256($wordsized(key), $wordsized(0x02)) — the storage slot of a
	// mapping value, parameterized by the template variable "key".
	SemanticDebugPointerExpression slot = SemanticDebugPointerExpression::keccak256({
		SemanticDebugPointerExpression::wordSized(SemanticDebugPointerExpression::variable("key")),
		SemanticDebugPointerExpression::wordSized(SemanticDebugPointerExpression::literal("0x02"))
	});

	BOOST_CHECK(slot.kind == SemanticDebugPointerExpression::Kind::Keccak256);
	BOOST_REQUIRE_EQUAL(slot.operands.size(), 2);
	BOOST_CHECK(slot.operands.at(0).kind == SemanticDebugPointerExpression::Kind::Resize);
	BOOST_CHECK(!slot.operands.at(0).value);
	BOOST_REQUIRE_EQUAL(slot.operands.at(0).operands.size(), 1);
	BOOST_CHECK(slot.operands.at(0).operands.front().kind == SemanticDebugPointerExpression::Kind::Variable);
	BOOST_REQUIRE_EQUAL(slot.operands.at(1).operands.size(), 1);
	BOOST_CHECK(slot.operands.at(1).operands.front().kind == SemanticDebugPointerExpression::Kind::Literal);
	BOOST_REQUIRE(slot.operands.at(1).operands.front().value);
	BOOST_CHECK_EQUAL(*slot.operands.at(1).operands.front().value, "0x02");
}

BOOST_AUTO_TEST_CASE(pointer_collections_compose)
{
	// group [ length region; define data := keccak256($wordsized(0x00)) in
	// list over $read(length) ] — the storage layout of a dynamic array.
	SemanticDebugPointer element = SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Storage,
		"values-item",
		SemanticDebugPointerExpression::sum({
			SemanticDebugPointerExpression::variable("values-data"),
			SemanticDebugPointerExpression::variable("values-index")
		})
	);
	SemanticDebugPointer pointer = SemanticDebugPointer::makeGroup({
		storageRegion("values-length", "0x00"),
		SemanticDebugPointer::scope(
			{{"values-data", SemanticDebugPointerExpression::keccak256({
				SemanticDebugPointerExpression::wordSized(SemanticDebugPointerExpression::literal("0x00"))
			})}},
			SemanticDebugPointer::list(
				SemanticDebugPointerExpression::read("values-length"),
				"values-index",
				std::move(element)
			)
		)
	});

	BOOST_CHECK(pointer.pointerClass == SemanticDebugPointer::Class::Group);
	BOOST_REQUIRE_EQUAL(pointer.group.size(), 2);
	BOOST_CHECK(pointer.group.at(0).pointerClass == SemanticDebugPointer::Class::Region);
	BOOST_CHECK(pointer.group.at(1).pointerClass == SemanticDebugPointer::Class::Scope);
	BOOST_REQUIRE_EQUAL(pointer.group.at(1).definitions.size(), 1);
	BOOST_CHECK_EQUAL(pointer.group.at(1).definitions.front().first, "values-data");
	BOOST_REQUIRE(pointer.group.at(1).scopeTarget);
	BOOST_CHECK(pointer.group.at(1).scopeTarget->pointerClass == SemanticDebugPointer::Class::List);
	BOOST_REQUIRE(pointer.group.at(1).scopeTarget->indexName);
	BOOST_CHECK_EQUAL(*pointer.group.at(1).scopeTarget->indexName, "values-index");
	BOOST_REQUIRE(pointer.group.at(1).scopeTarget->count);
	BOOST_CHECK(pointer.group.at(1).scopeTarget->count->kind == SemanticDebugPointerExpression::Kind::Read);
	BOOST_REQUIRE(pointer.group.at(1).scopeTarget->listElement);
	BOOST_CHECK(pointer.group.at(1).scopeTarget->listElement->pointerClass == SemanticDebugPointer::Class::Region);
}

BOOST_AUTO_TEST_CASE(recursive_types_reference_by_id)
{
	// struct Node { uint256 value; Node[] children; } - the table is
	// normalized, so the cycle is closed by an `{"id": ...}` reference and the
	// documents pass through serialization untouched.
	SemanticDebugDataTable table;
	table.setType("t_uint256", Json{{"kind", "uint"}, {"bits", 256}});
	table.setType("t_array$_t_struct$_Node", Json{
		{"kind", "array"},
		{"contains", Json{{"type", Json{{"id", "t_struct$_Node"}}}}}});
	table.setType("t_struct$_Node", Json{
		{"kind", "struct"},
		{"contains", Json::array({
			Json{{"name", "value"}, {"type", Json{{"id", "t_uint256"}}}},
			Json{{"name", "children"}, {"type", Json{{"id", "t_array$_t_struct$_Node"}}}}})},
		{"definition", Json{{"name", "Node"}}}});

	Json serialized = semanticDebugDataToJson(table);
	BOOST_CHECK_EQUAL(serialized["resources"]["types"].size(), 3);
	BOOST_CHECK_EQUAL(
		serialized["resources"]["types"]["t_array$_t_struct$_Node"]["contains"]["type"]["id"].get<std::string>(),
		"t_struct$_Node");

	SemanticDebugDataTable read = semanticDebugDataFromJson(serialized);
	BOOST_REQUIRE(read.findType("t_struct$_Node") != nullptr);
	BOOST_CHECK(semanticDebugDataToJson(read) == serialized);
}

BOOST_AUTO_TEST_CASE(semantic_debug_data_table_uses_ast_id)
{
	SemanticDebugScope scope;
	auto semanticDebugScope = std::make_shared<SemanticDebugScope const>(std::move(scope));

	SemanticDebugDataTable table;
	BOOST_CHECK(table.empty());

	table.set(23, semanticDebugScope);

	BOOST_CHECK(!table.empty());
	BOOST_CHECK(table.find(23) == semanticDebugScope);
	BOOST_CHECK(!table.find(24));
	BOOST_CHECK(!table.find(23, 1));
	BOOST_CHECK(table.find(SemanticDebugDataTable::Key{23, 0}) == semanticDebugScope);
}

BOOST_AUTO_TEST_CASE(semantic_debug_data_table_json_roundtrip)
{
	Json containerType{
		{"kind", "struct"},
		{"contains", Json::array({Json{{"name", "member"}, {"type", Json{{"id", "t_uint256"}}}}})},
		{"definition", Json{
			{"name", "Container"},
			{"location", Json{
				{"range", Json{{"length", 16}, {"offset", 4}}},
				{"source", Json{{"id", 0}}}}}}}};

	// A mapping value template, published in the pointer resources and
	// instantiated by the consumer with the key.
	SemanticDebugPointer mappingValue = storageRegion("value", "0x00");
	mappingValue.slot = SemanticDebugPointerExpression::keccak256({
		SemanticDebugPointerExpression::wordSized(SemanticDebugPointerExpression::variable("key")),
		SemanticDebugPointerExpression::wordSized(SemanticDebugPointerExpression::literal("0x01"))
	});
	mappingValue.expectedParameters = {"key"};

	SemanticDebugPointer pointer = SemanticDebugPointer::scope(
		{{"slot", SemanticDebugPointerExpression::keccak256({
			SemanticDebugPointerExpression::wordSized(SemanticDebugPointerExpression::literal("0x01"))
		})}},
		SemanticDebugPointer::conditional(
			SemanticDebugPointerExpression::read("condition"),
			SemanticDebugPointer::templateReference("mapping-value", {{"value", "renamed-value"}}),
			SemanticDebugPointer::region(
				SemanticDebugPointer::Location::Storage,
				"fallback",
				SemanticDebugPointerExpression::variable("slot"),
				SemanticDebugPointerExpression::literal("0x00"),
				SemanticDebugPointerExpression::wordSize()
			)
		)
	);

	SemanticDebugVariable variable;
	variable.identifier = "value";
	variable.declarationASTID = 9;
	variable.declarationSourceRange = SemanticDebugSourceRange{0, 21, 5};
	variable.typeID = "t_struct$_Container";
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = std::move(pointer);

	SemanticDebugScope scope;
	scope.variableDefinitions.emplace_back(std::move(variable));

	SemanticDebugDataTable table;
	table.setContractName("ContainerContract");
	table.setType("t_struct$_Container", std::move(containerType));
	table.setType("t_uint256", Json{{"kind", "uint"}, {"bits", 256}});
	table.setPointerTemplate("mapping-value", std::move(mappingValue));
	table.set(42, std::make_shared<SemanticDebugScope const>(std::move(scope)));

	Json serialized = semanticDebugDataToJson(table);
	BOOST_CHECK_EQUAL(serialized["format"].get<std::string>(), SemanticDebugDataFormat);
	BOOST_CHECK_EQUAL(serialized["version"].get<unsigned>(), SemanticDebugDataFormatVersion);
	BOOST_CHECK_EQUAL(serialized["contractName"], "ContainerContract");
	// The pointer template table mirrors ethdebug.resources.pointers.
	BOOST_CHECK(serialized["resources"]["pointers"]["mapping-value"]["expect"] == Json::array({"key"}));
	// Field names are identical in the JSON form and the compiler structures.
	Json const& serializedVariable = serialized["scopes"]["42"]["0"]["variableDefinitions"][0];
	BOOST_CHECK_EQUAL(serializedVariable["declarationASTID"].get<int64_t>(), 9);
	BOOST_CHECK_EQUAL(serializedVariable["declarationSourceRange"]["source"]["id"].get<uint64_t>(), 0);
	BOOST_CHECK_EQUAL(serializedVariable["declarationSourceRange"]["range"]["offset"].get<int>(), 21);
	BOOST_CHECK_EQUAL(serializedVariable["typeID"].get<std::string>(), "t_struct$_Container");
	BOOST_CHECK_EQUAL(serializedVariable["phase"].get<std::string>(), "materialized");
	BOOST_CHECK(semanticDebugDataToJson(semanticDebugDataFromJson(serialized)) == serialized);
}

BOOST_AUTO_TEST_CASE(semantic_debug_data_json_rejects_unknown_version_and_malformed_keys)
{
	Json serialized = semanticDebugDataToJson({});
	serialized["version"] = SemanticDebugDataFormatVersion + 1;
	BOOST_CHECK_THROW(semanticDebugDataFromJson(serialized), SemanticDebugDataSerializationError);
	serialized["version"] = SemanticDebugDataFormatVersion;

	Json const emptyScope{{"variableDefinitions", Json::array()}};
	for (std::string const& astIDKey: {"abc", "01", "1.5", "", "-0"})
	{
		Json malformed = serialized;
		malformed["scopes"][astIDKey] = Json{{"0", emptyScope}};
		BOOST_CHECK_THROW(semanticDebugDataFromJson(malformed), SemanticDebugDataSerializationError);
	}
	for (std::string const& instanceKey: {"-1", "x", "00"})
	{
		Json malformed = serialized;
		malformed["scopes"]["1"] = Json{{instanceKey, emptyScope}};
		BOOST_CHECK_THROW(semanticDebugDataFromJson(malformed), SemanticDebugDataSerializationError);
	}

	// A negative AST ID is unusual but within the documented int64 range.
	serialized["scopes"]["-1"] = Json{{"0", emptyScope}};
	BOOST_CHECK(semanticDebugDataFromJson(serialized).find(-1) != nullptr);
}

BOOST_AUTO_TEST_CASE(semantic_debug_data_types_are_shared_by_id)
{
	auto makeVariable = [&](std::string _name) {
		SemanticDebugVariable variable;
		variable.identifier = std::move(_name);
		variable.typeID = "t_uint256";
		return variable;
	};
	SemanticDebugScope scope;
	scope.variableDefinitions = {makeVariable("a"), makeVariable("b")};

	SemanticDebugDataTable table;
	table.setType("t_uint256", Json{{"kind", "uint"}, {"bits", 256}});
	table.set(1, std::make_shared<SemanticDebugScope const>(std::move(scope)));

	Json serialized = semanticDebugDataToJson(table);
	BOOST_CHECK_EQUAL(serialized["resources"]["types"].size(), 1);
	Json const& variables = serialized["scopes"]["1"]["0"]["variableDefinitions"];
	// Variables carry only the ID; the document lives in the table.
	BOOST_CHECK(!variables[0].contains("type"));
	BOOST_CHECK(!variables[1].contains("type"));

	SemanticDebugDataTable read = semanticDebugDataFromJson(serialized);
	BOOST_REQUIRE(read.findType("t_uint256") != nullptr);
	BOOST_CHECK_EQUAL((*read.findType("t_uint256"))["bits"].get<unsigned>(), 256);
	BOOST_CHECK(semanticDebugDataToJson(read) == serialized);
}

BOOST_AUTO_TEST_CASE(semantic_debug_data_variable_updates_roundtrip)
{
	// The dbg.value analogue: a statement-level rebinding of a variable, here
	// a spill to memory that keeps the phase and a drop to optimized-out.
	SemanticDebugVariableUpdate spilled;
	spilled.variableASTID = 42;
	spilled.pointer = SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Memory,
		"spill",
		std::nullopt,
		SemanticDebugPointerExpression::literal("0x80"),
		SemanticDebugPointerExpression::wordSize());

	SemanticDebugVariableUpdate dropped;
	dropped.variableASTID = 42;
	dropped.phase = SemanticDebugVariablePhase::OptimizedOut;

	SemanticDebugScope scope;
	scope.variableUpdates = {spilled, dropped};
	SemanticDebugDataTable table;
	table.set(7, std::make_shared<SemanticDebugScope const>(std::move(scope)));

	Json serialized = semanticDebugDataToJson(table);
	BOOST_CHECK(semanticDebugDataToJson(semanticDebugDataFromJson(serialized)) == serialized);
	Json const& updates = serialized["scopes"]["7"]["0"]["variableUpdates"];
	BOOST_REQUIRE_EQUAL(updates.size(), 2);
	// A pointer-only update leaves the phase alone.
	BOOST_CHECK(!updates[0].contains("phase"));
	// A change to optimized-out clears the previous pointer.
	BOOST_CHECK_EQUAL(updates[1]["phase"].get<std::string>(), "optimized-out");
	BOOST_CHECK(!updates[1].contains("pointer"));

	// An update that changes nothing, or claims a pointer for an unavailable
	// value, is malformed.
	Json malformed = serialized;
	malformed["scopes"]["7"]["0"]["variableUpdates"][1]["pointer"] = updates[0]["pointer"];
	BOOST_CHECK_THROW(semanticDebugDataFromJson(malformed), SemanticDebugDataSerializationError);
	malformed = serialized;
	malformed["scopes"]["7"]["0"]["variableUpdates"][0].erase("pointer");
	BOOST_CHECK_THROW(semanticDebugDataFromJson(malformed), SemanticDebugDataSerializationError);
}

BOOST_AUTO_TEST_CASE(semantic_debug_data_table_distinguishes_scope_instances)
{
	// A cloned scope keeps its AST ID and gets its own instance; the two
	// records must coexist under the same AST ID and round-trip.
	SemanticDebugDataTable table;
	table.set({9, 0}, std::make_shared<SemanticDebugScope const>());
	table.set({9, 2}, std::make_shared<SemanticDebugScope const>());

	Json serialized = semanticDebugDataToJson(table);
	BOOST_REQUIRE_EQUAL(serialized["scopes"].size(), 1);
	BOOST_CHECK_EQUAL(serialized["scopes"]["9"].size(), 2);
	// Instance 0 is written explicitly.
	BOOST_CHECK(serialized["scopes"]["9"].contains("0"));
	BOOST_CHECK(serialized["scopes"]["9"].contains("2"));

	SemanticDebugDataTable read = semanticDebugDataFromJson(serialized);
	BOOST_CHECK(read.find({9, 0}) != nullptr);
	BOOST_CHECK(read.find({9, 2}) != nullptr);
	BOOST_CHECK(read.find({9, 1}) == nullptr);
	BOOST_CHECK(semanticDebugDataToJson(read) == serialized);
}

BOOST_AUTO_TEST_CASE(semantic_debug_data_variable_phases_roundtrip)
{
	// A materialized variable has a pointer; the other phases do not.
	SemanticDebugScope scope;
	SemanticDebugVariable materialized;
	materialized.phase = SemanticDebugVariablePhase::Materialized;
	materialized.pointer = storageRegion("value", "0x00");
	scope.variableDefinitions.emplace_back(std::move(materialized));
	SemanticDebugVariable computed;
	computed.phase = SemanticDebugVariablePhase::Computed;
	scope.variableDefinitions.emplace_back(std::move(computed));
	SemanticDebugVariable optimizedOut;
	optimizedOut.phase = SemanticDebugVariablePhase::OptimizedOut;
	scope.variableDefinitions.emplace_back(std::move(optimizedOut));

	SemanticDebugDataTable table;
	table.set(1, std::make_shared<SemanticDebugScope const>(std::move(scope)));
	Json const serialized = semanticDebugDataToJson(table);
	Json const& variables = serialized["scopes"]["1"]["0"]["variableDefinitions"];
	BOOST_REQUIRE_EQUAL(variables.size(), 3);
	BOOST_CHECK_EQUAL(variables[0]["phase"].get<std::string>(), "materialized");
	BOOST_CHECK_EQUAL(variables[1]["phase"].get<std::string>(), "computed");
	BOOST_CHECK_EQUAL(variables[2]["phase"].get<std::string>(), "optimized-out");
	BOOST_CHECK(semanticDebugDataToJson(semanticDebugDataFromJson(serialized)) == serialized);

	// The invariant is enforced in both directions.
	SemanticDebugVariable inconsistent;
	inconsistent.phase = SemanticDebugVariablePhase::Materialized;
	SemanticDebugScope inconsistentScope;
	inconsistentScope.variableDefinitions.emplace_back(std::move(inconsistent));
	SemanticDebugDataTable inconsistentTable;
	inconsistentTable.set(1, std::make_shared<SemanticDebugScope const>(std::move(inconsistentScope)));
	BOOST_CHECK_THROW(semanticDebugDataToJson(inconsistentTable), SemanticDebugDataSerializationError);

	Json malformed = serialized;
	malformed["scopes"]["1"]["0"]["variableDefinitions"][1]["pointer"] = variables[0]["pointer"];
	BOOST_CHECK_THROW(semanticDebugDataFromJson(malformed), SemanticDebugDataSerializationError);
}

BOOST_AUTO_TEST_CASE(yul_locals_use_the_internal_expression_prefix)
{
	SemanticDebugVariable variable;
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Stack,
		"x",
		SemanticDebugPointerExpression::yulLocal("var_x_1"));
	SemanticDebugScope scope;
	scope.variableDefinitions.emplace_back(std::move(variable));
	SemanticDebugDataTable table;
	table.set(1, std::make_shared<SemanticDebugScope const>(std::move(scope)));

	Json const serialized = semanticDebugDataToJson(table);
	Json const& slot = serialized["scopes"]["1"]["0"]["variableDefinitions"][0]["pointer"]["slot"];
	BOOST_CHECK((slot == Json{{"$$yulLocal", "var_x_1"}}));
	SemanticDebugDataTable const read = semanticDebugDataFromJson(serialized);
	BOOST_REQUIRE(read.find(1));
	BOOST_REQUIRE(read.find(1)->variableDefinitions.front().pointer->slot);
	BOOST_CHECK(
		read.find(1)->variableDefinitions.front().pointer->slot->kind ==
		SemanticDebugPointerExpression::Kind::YulLocal);

	// Any other internal expression is unknown to the reader.
	Json malformed = serialized;
	malformed["scopes"]["1"]["0"]["variableDefinitions"][0]["pointer"]["slot"] = Json{{"$$other", "x"}};
	BOOST_CHECK_THROW(semanticDebugDataFromJson(malformed), SemanticDebugDataSerializationError);
}

BOOST_AUTO_TEST_CASE(template_references_must_resolve)
{
	SemanticDebugVariable variable;
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = SemanticDebugPointer::templateReference("storage_1_2");
	SemanticDebugScope scope;
	scope.variableDefinitions.emplace_back(std::move(variable));
	SemanticDebugDataTable table;
	table.set(1, std::make_shared<SemanticDebugScope const>(std::move(scope)));

	// Nothing defines the template: rejected on deserialization.
	BOOST_CHECK_THROW(semanticDebugDataFromJson(semanticDebugDataToJson(table)), SemanticDebugDataSerializationError);

	// The sidecar's pointer table defines it.
	table.setPointerTemplate("storage_1_2", storageRegion("value", "0x02"));
	Json const serialized = semanticDebugDataToJson(table);
	BOOST_CHECK(serialized["resources"]["pointers"]["storage_1_2"]["expect"] == Json::array());
	BOOST_CHECK(semanticDebugDataToJson(semanticDebugDataFromJson(serialized)) == serialized);

	// A local templates block defines it for references inside its target.
	SemanticDebugPointer local = SemanticDebugPointer::withTemplates(
		{{"local-slot", storageRegion("local", "0x03")}},
		SemanticDebugPointer::templateReference("local-slot"));
	SemanticDebugVariable localVariable;
	localVariable.phase = SemanticDebugVariablePhase::Materialized;
	localVariable.pointer = std::move(local);
	SemanticDebugScope localScope;
	localScope.variableDefinitions.emplace_back(std::move(localVariable));
	SemanticDebugDataTable localTable;
	localTable.set(2, std::make_shared<SemanticDebugScope const>(std::move(localScope)));
	Json const localSerialized = semanticDebugDataToJson(localTable);
	BOOST_CHECK(localSerialized["scopes"]["2"]["0"]["variableDefinitions"][0]["pointer"].contains("templates"));
	BOOST_CHECK(semanticDebugDataToJson(semanticDebugDataFromJson(localSerialized)) == localSerialized);
}

BOOST_AUTO_TEST_CASE(number_literals_deserialize_as_hex_literals)
{
	Json serialized = semanticDebugDataToJson({});
	serialized["resources"]["pointers"]["slot-one"] = Json{
		{"expect", Json::array()},
		{"for", Json{{"location", "storage"}, {"name", "value"}, {"slot", 1}, {"offset", 0}, {"length", 32}}}
	};
	SemanticDebugDataTable table = semanticDebugDataFromJson(serialized);
	SemanticDebugPointer const* pointer = table.findPointerTemplate("slot-one");
	BOOST_REQUIRE(pointer);
	BOOST_REQUIRE(pointer->slot && pointer->slot->value);
	BOOST_CHECK_EQUAL(*pointer->slot->value, "0x01");
	// The schema allows numbers; the compiler carries and re-emits them as hex literals.
	Json const reserialized = semanticDebugDataToJson(table)["resources"]["pointers"]["slot-one"]["for"];
	BOOST_CHECK_EQUAL(reserialized["slot"].get<std::string>(), "0x01");
	BOOST_CHECK_EQUAL(reserialized["offset"].get<std::string>(), "0x00");
	BOOST_CHECK_EQUAL(reserialized["length"].get<std::string>(), "0x20");
}

BOOST_AUTO_TEST_CASE(pointer_resources_reject_internal_expressions)
{
	Json serialized = semanticDebugDataToJson({});
	serialized["resources"]["pointers"]["local"] = Json{
		{"expect", Json::array()},
		{"for", Json{{"location", "stack"}, {"name", "value"}, {"slot", Json{{"$$yulLocal", "var_value"}}}}}
	};
	BOOST_CHECK_THROW(semanticDebugDataFromJson(serialized), SemanticDebugDataSerializationError);
}

BOOST_AUTO_TEST_CASE(malformed_pointer_documents_are_rejected)
{
	auto sidecarWithPointer = [](Json _pointer) {
		Json serialized = semanticDebugDataToJson({});
		Json const variable{{"phase", "materialized"}, {"pointer", std::move(_pointer)}};
		serialized["scopes"]["1"] = Json{{"0", Json{{"variableDefinitions", Json::array({variable})}}}};
		return serialized;
	};
	auto rejects = [&](Json _pointer) {
		BOOST_CHECK_THROW(semanticDebugDataFromJson(sidecarWithPointer(std::move(_pointer))), SemanticDebugDataSerializationError);
	};

	BOOST_CHECK_NO_THROW(semanticDebugDataFromJson(sidecarWithPointer(Json{{"location", "storage"}, {"slot", "0x0"}})));
	// Only the schema's locations.
	rejects(Json{{"location", "unknown"}, {"slot", "0x0"}});
	// A segment location needs a slot, a slice location an offset and a length.
	rejects(Json{{"location", "storage"}, {"offset", "0x0"}});
	rejects(Json{{"location", "memory"}, {"offset", "0x0"}});
	// $sized takes a positive size.
	rejects(Json{{"location", "storage"}, {"slot", Json{{"$sized0", "0x0"}}}});
	// No members outside the schema.
	rejects(Json{{"location", "storage"}, {"slot", "0x0"}, {"extra", true}});
	// A group has at least one member.
	rejects(Json{{"group", Json::array()}});
	// A template is not a pointer; it lives in the resources or a templates block.
	rejects(Json{{"expect", Json::array()}, {"for", Json{{"location", "storage"}, {"slot", "0x0"}}}});
	// Nesting is bounded.
	Json nested{{"location", "storage"}, {"slot", "0x0"}};
	for (size_t depth = 0; depth < 300; ++depth)
		nested = Json{{"group", Json::array({nested})}};
	rejects(nested);
}

BOOST_AUTO_TEST_CASE(free_names_resolve_through_templates_and_terminate_on_cycles)
{
	SemanticDebugDataTable table;
	table.setPointerTemplate("a", SemanticDebugPointer::templateReference("b"));
	table.setPointerTemplate("b", SemanticDebugPointer::templateReference("a"));
	// A cyclic template pair resolves to no names rather than recursing forever.
	BOOST_CHECK(semanticDebugPointerFreeNames(SemanticDebugPointer::templateReference("a"), table).empty());

	SemanticDebugPointer open = storageRegion("value", "0x0");
	open.slot = SemanticDebugPointerExpression::variable("key");
	table.setPointerTemplate("open", open);
	BOOST_CHECK((semanticDebugPointerFreeNames(SemanticDebugPointer::templateReference("open"), table) == std::set<std::string>{"key"}));

	// The expected parameters of a template are bound by its instantiation.
	open.expectedParameters = {"key"};
	table.setPointerTemplate("closed", open);
	BOOST_CHECK(semanticDebugPointerFreeNames(SemanticDebugPointer::templateReference("closed"), table).empty());

	// A Yul local is a name only the Yul stage can supply.
	SemanticDebugPointer local = storageRegion("value", "0x0");
	local.slot = SemanticDebugPointerExpression::yulLocal("var_value");
	BOOST_CHECK((semanticDebugPointerFreeNames(local, table) == std::set<std::string>{"var_value"}));
	BOOST_CHECK(semanticDebugPointerHasInternalExpression(local));
	BOOST_CHECK(!semanticDebugPointerHasInternalExpression(open));
}

BOOST_AUTO_TEST_SUITE_END()

} // namespace solidity::langutil::test
