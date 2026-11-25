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

#include <liblangutil/SemanticDebugDataTable.h>

#include <libsolutil/JSON.h>

#include <boost/test/unit_test.hpp>

#include <memory>
#include <optional>
#include <utility>

using namespace solidity;
using namespace solidity::langutil;
using namespace solidity::langutil::ethdebug;

BOOST_AUTO_TEST_SUITE(EthdebugSemanticData)

BOOST_AUTO_TEST_CASE(table_copies_own_resources_and_share_immutable_scopes)
{
	SemanticDebugDataTable originalTable;
	originalTable.setType("array", schema::Type{schema::Type::Array{
		.contains = {
			.name = std::nullopt,
			.type = schema::Type::Specifier{std::make_unique<schema::Type const>(schema::Type{schema::Type::UInt{8}})},
		},
		.count = std::nullopt,
	}});
	originalTable.setPointerTemplate("storage", schema::Pointer::Template{
		{"slot"},
		std::make_unique<schema::Pointer const>(schema::Pointer{schema::Pointer::Region{
			"value",
			schema::Pointer::Location::Storage,
			schema::Pointer::Expression{schema::Pointer::Variable{"slot"}},
		}}),
	});
	auto scope = std::make_shared<SemanticDebugScope const>();
	originalTable.set(ScopeID{1, 0}, scope);

	SemanticDebugDataTable copiedTable{originalTable};
	BOOST_CHECK(copiedTable.find(ScopeID{1, 0}) == scope);
	BOOST_CHECK(copiedTable.findType("array") != originalTable.findType("array"));
	BOOST_REQUIRE(copiedTable.findType("array") != nullptr);
	BOOST_REQUIRE(copiedTable.findPointerTemplate("storage") != nullptr);
	BOOST_CHECK(copiedTable.findPointerTemplate("storage")->body.get() != originalTable.findPointerTemplate("storage")->body.get());
	BOOST_CHECK_EQUAL(Json(copiedTable.types()).dump(), Json(originalTable.types()).dump());
	BOOST_CHECK_EQUAL(Json(copiedTable.pointerTemplates()).dump(), Json(originalTable.pointerTemplates()).dump());
	copiedTable.merge(originalTable);
	BOOST_CHECK_EQUAL(copiedTable.scopes().size(), 1);
	BOOST_CHECK(copiedTable.find({1, 0}) == scope);

	SemanticDebugDataTable assignedTable;
	assignedTable = copiedTable;
	assignedTable.merge(assignedTable);
	originalTable = SemanticDebugDataTable{};
	BOOST_CHECK_EQUAL(Json(assignedTable.types()).dump(), Json(copiedTable.types()).dump());
	BOOST_CHECK_EQUAL(Json(assignedTable.pointerTemplates()).dump(), Json(copiedTable.pointerTemplates()).dump());
}

BOOST_AUTO_TEST_CASE(table_merge_adds_resources_and_replaces_scope_records)
{
	SemanticDebugDataTable table;
	table.setType("t_uint256", schema::Type{schema::Type::UInt{256}});
	table.setPointerTemplate("storage", schema::templateFromJSON(Json::parse(R"({
    "expect": ["slot"],
    "for": {"location": "storage", "slot": "slot"}
})"), "template"));
	auto originalScope = std::make_shared<SemanticDebugScope const>();
	table.set({1, 0}, originalScope);
	table.set({2, 0}, originalScope);

	SemanticDebugDataTable other;
	other.setContractName("C");
	other.setType("t_uint256", schema::Type{schema::Type::UInt{256}});
	other.setType("t_bool", schema::Type{schema::Type::Bool{}});
	other.setPointerTemplate("memory", schema::templateFromJSON(Json::parse(R"({
    "expect": ["offset"],
    "for": {"location": "memory", "offset": "offset", "length": "0x20"}
})"), "template"));
	SemanticDebugVariable variable;
	variable.identifier = "stored";
	variable.typeID = "t_uint256";
	variable.phase = SemanticDebugVariablePhase::Materialized;
	variable.pointer = schema::pointerFromJSON(Json::parse(R"({"location": "storage", "slot": "0x00"})"), "pointer");
	SemanticDebugScope scope;
	scope.variableDefinitions.emplace_back(std::move(variable));
	auto updatedScope = std::make_shared<SemanticDebugScope const>(std::move(scope));
	other.set({1, 0}, updatedScope);
	other.set({3, 0}, originalScope);

	table.merge(other);
	BOOST_REQUIRE(table.contractName().has_value());
	BOOST_CHECK_EQUAL(*table.contractName(), "C");
	BOOST_CHECK_EQUAL(table.types().size(), 2);
	BOOST_CHECK_EQUAL(table.pointerTemplates().size(), 2);
	BOOST_CHECK(table.findType("t_uint256") != nullptr);
	BOOST_CHECK(table.findType("t_bool") != nullptr);
	BOOST_CHECK(table.findPointerTemplate("storage") != nullptr);
	BOOST_CHECK(table.findPointerTemplate("memory") != nullptr);
	BOOST_CHECK(table.find({1, 0}) == updatedScope);
	BOOST_CHECK(table.find({2, 0}) == originalScope);
	BOOST_CHECK(table.find({3, 0}) == originalScope);
}

BOOST_AUTO_TEST_SUITE_END()
