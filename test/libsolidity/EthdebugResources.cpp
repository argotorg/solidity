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

#include <libsolidity/interface/Ethdebug.h>
#include <libsolidity/interface/EthdebugTypeRegistry.h>

#include <libsolidity/ast/TypeProvider.h>

#include <libsolutil/JSON.h>

#include <test/libsolidity/AnalysisFramework.h>
#include <test/Common.h>

#include <boost/test/unit_test.hpp>

#include <map>
#include <set>
#include <string>

using solidity::test::CommonOptions;

namespace solidity::frontend::test
{

namespace
{

void checkTypeIDs(Json const& _types, std::set<std::string> const& _expected)
{
	std::set<std::string> typeIDs;
	for (auto it = _types.begin(); it != _types.end(); ++it)
		typeIDs.insert(it.key());
	BOOST_CHECK_EQUAL_COLLECTIONS(typeIDs.begin(), typeIDs.end(), _expected.begin(), _expected.end());
}

}

BOOST_AUTO_TEST_SUITE(EthdebugResources)

BOOST_AUTO_TEST_CASE(function_tuple_arguments_and_returns_are_not_flattened)
{
	TypePointers const components{TypeProvider::uint(32), TypeProvider::boolean()};
	TupleType const* tupleType = TypeProvider::tuple(components);
	TupleType const* outerTupleType = TypeProvider::tuple(TypePointers{tupleType});
	FunctionType const* multipleArgumentFunctionType = TypeProvider::function(
		components,
		components,
		{"left", "right"},
		{"left", "right"}
	);
	FunctionType const* tupleArgumentFunctionType = TypeProvider::function(
		TypePointers{tupleType},
		TypePointers{tupleType},
		{"pair"},
		{"pair"}
	);
	std::map<std::string, unsigned> const sourceIndices;
	ethdebug::TypeRegistry registry{sourceIndices};
	registry.registerTypeDecomposition(*multipleArgumentFunctionType);
	registry.registerTypeDecomposition(*tupleArgumentFunctionType);
	Json const types = registry.takeDocuments();

	BOOST_CHECK(multipleArgumentFunctionType->identifier() != tupleArgumentFunctionType->identifier());
	BOOST_CHECK_EQUAL(types[tupleType->identifier()]["contains"].size(), 2);
	BOOST_CHECK_EQUAL(types[outerTupleType->identifier()]["contains"].size(), 1);
	BOOST_CHECK_EQUAL(
		types[outerTupleType->identifier()]["contains"][0].dump(),
		Json({{"type", {{"id", tupleType->identifier()}}}}).dump()
	);
	for (std::string const field: {"parameters", "returns"})
	{
		BOOST_CHECK_EQUAL(
			types[multipleArgumentFunctionType->identifier()]["contains"][field].dump(),
			Json({{"type", {{"id", tupleType->identifier()}}}}).dump()
		);
		BOOST_CHECK_EQUAL(
			types[tupleArgumentFunctionType->identifier()]["contains"][field].dump(),
			Json({{"type", {{"id", outerTupleType->identifier()}}}}).dump()
		);
	}
}

BOOST_FIXTURE_TEST_CASE(callable_and_import_boundaries, AnalysisFramework)
{
	BOOST_REQUIRE_MESSAGE(runFramework({
		{"consumer.sol",
			R"(
			pragma solidity >=0.0;
			import {selected, I, L} from "definitions.sol";
			contract C {
				using {selected} for uint64;
				function f(uint8) external returns (uint16) {
					uint64(1).selected();
					L.internalFn(1);
					I(address(1)).externalFn(1);
					I.externalFn.selector;
					I(address(1)).externalFn.address;
					onlyReferenced;
					if (false) conditional(1);
					return 0;
				}
				function onlyReferenced(uint136) internal pure returns (uint144) {
					uint168 local;
					return 0;
				}
				function conditional(uint152) internal pure returns (uint160) {
					uint176 local;
					return 0;
				}
				function unused(uint184) internal pure { uint192 local; }
			}
		)"},
		{"definitions.sol",
			R"(
			pragma solidity >=0.0;
			function selected(uint64) pure returns (uint72) { uint80 local; return 0; }
			function unused(uint200) pure returns (uint208) { uint216 local; return 0; }
			interface I { function externalFn(uint48) external returns (uint56); }
			library L {
				function internalFn(uint88) internal pure returns (uint96) { uint104 local; return 0; }
				function externalFn(uint24) external pure returns (uint32) { uint40 local; return 0; }
				function unused(uint112) internal pure { uint120 local; }
			}
			abstract contract Unimported {
				function f(uint224) external virtual returns (uint232);
			}
		)"},
	}, PipelineStage::Analysis), formatErrors(compiler().errors()));

	ethdebug::Resources const callerResources = ethdebug::resources(
		compiler().contractDefinition("consumer.sol:C"),
		compiler().sourceIndices()
	);
	checkTypeIDs(
		Json(callerResources.types),
		{
			"t_uint8",
			"t_uint16",
			"t_uint64",
			"t_uint72",
			"t_uint80",
			"t_uint88",
			"t_uint96",
			"t_uint104",
			"t_uint136",
			"t_uint144",
			"t_uint152",
			"t_uint160",
			"t_uint168",
			"t_uint176",
			"t_tuple$_t_uint8_$",
			"t_tuple$_t_uint16_$",
			"t_tuple$_t_uint64_$",
			"t_tuple$_t_uint72_$",
			"t_tuple$_t_uint88_$",
			"t_tuple$_t_uint96_$",
			"t_tuple$_t_uint136_$",
			"t_tuple$_t_uint144_$",
			"t_tuple$_t_uint152_$",
			"t_tuple$_t_uint160_$",
		}
	);
	BOOST_CHECK(callerResources.pointers.empty());
	checkTypeIDs(
		compiler().ethdebug()["types"],
		{
			"t_uint8",
			"t_uint16",
			"t_uint24",
			"t_uint32",
			"t_uint40",
			"t_uint48",
			"t_uint56",
			"t_uint64",
			"t_uint72",
			"t_uint80",
			"t_uint88",
			"t_uint96",
			"t_uint104",
			"t_uint136",
			"t_uint144",
			"t_uint152",
			"t_uint160",
			"t_uint168",
			"t_uint176",
			"t_uint224",
			"t_uint232",
			"t_tuple$_t_uint8_$",
			"t_tuple$_t_uint16_$",
			"t_tuple$_t_uint24_$",
			"t_tuple$_t_uint32_$",
			"t_tuple$_t_uint48_$",
			"t_tuple$_t_uint56_$",
			"t_tuple$_t_uint64_$",
			"t_tuple$_t_uint72_$",
			"t_tuple$_t_uint88_$",
			"t_tuple$_t_uint96_$",
			"t_tuple$_t_uint136_$",
			"t_tuple$_t_uint144_$",
			"t_tuple$_t_uint152_$",
			"t_tuple$_t_uint160_$",
			"t_tuple$_t_uint224_$",
			"t_tuple$_t_uint232_$",
		}
	);
}

BOOST_FIXTURE_TEST_CASE(local_scopes, AnalysisFramework)
{
	if (!CommonOptions::get().evmVersion().supportsReturndata())
		return;

	BOOST_REQUIRE_MESSAGE(runFramework(R"(
		pragma solidity >=0.0;
		interface I { function value() external returns (uint8); }
		contract C {
			constructor(uint32) { uint40 constructorLocal; }
			modifier m(uint16) { uint24 modifierLocal; _; }
			function f(uint48) external m(1) returns (uint56) {
				uint64 local;
				{ uint72 nested; }
				for (uint80 i; i < 1; ++i) {}
				try I(address(1)).value() returns (uint8 success) {
					uint88 successLocal;
				} catch Error(string memory reason) {
					uint96 errorLocal;
				} catch Panic(uint256 code) {
					uint104 panicLocal;
				} catch (bytes memory data) {
					uint112 catchLocal;
				}
				if (true) { uint120 ifLocal; }
				unchecked { uint128 uncheckedLocal; }
				(uint136 first, , uint144 last) = (1, 2, 3);
				return 0;
			}
		}
	)", PipelineStage::Analysis), formatErrors(compiler().errors()));

	ethdebug::Resources const resources = ethdebug::resources(compiler().contractDefinition(":C"), compiler().sourceIndices());
	checkTypeIDs(
		Json(resources.types),
		{
			"t_uint8",
			"t_uint16",
			"t_uint24",
			"t_uint32",
			"t_uint40",
			"t_uint48",
			"t_uint56",
			"t_uint64",
			"t_uint72",
			"t_uint80",
			"t_uint88",
			"t_uint96",
			"t_uint104",
			"t_uint112",
			"t_uint120",
			"t_uint128",
			"t_uint136",
			"t_uint144",
			"t_uint256",
			"t_string_storage",
			"t_bytes_storage",
			"t_tuple$_t_uint16_$",
			"t_tuple$_t_uint32_$",
			"t_tuple$_t_uint48_$",
			"t_tuple$_t_uint56_$",
		}
	);
	BOOST_CHECK(resources.pointers.contains("memory-t_string_storage"));
	BOOST_CHECK(resources.pointers.contains("memory-t_bytes_storage"));
	BOOST_CHECK_EQUAL(resources.pointers.size(), 2);
}

BOOST_FIXTURE_TEST_CASE(file_constants_without_contracts, AnalysisFramework)
{
	BOOST_REQUIRE_MESSAGE(runFramework(R"(
		pragma solidity >=0.0;
		uint8 constant UNUSED = 1;
		string constant TEXT = "text";
	)", PipelineStage::Analysis), formatErrors(compiler().errors()));

	Json const resources = compiler().ethdebug();
	checkTypeIDs(resources["types"], {"t_uint8", "t_string_storage"});
	BOOST_CHECK(resources["pointers"].empty());
}

BOOST_AUTO_TEST_SUITE_END()

}
