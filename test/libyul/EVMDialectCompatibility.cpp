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

#include <libyul/backends/evm/EVMDialect.h>

#include <libsolidity/util/SoltestErrors.h>

#include <boost/test/data/test_case.hpp>
#include <boost/test/data/monomorphic.hpp>
#include <boost/test/unit_test.hpp>

#include <range/v3/view/zip.hpp>
#include <range/v3/range_concepts.hpp>

#include <fmt/format.h>

#include <cstdint>
#include <optional>
#include <vector>

namespace bdata = boost::unit_test::data;

using namespace solidity;
using namespace solidity::yul;

namespace
{

struct EVMDialectConfigurationToTest
{
	EVMDialect const& dialect() const
	{
		return objectAccess ? EVMDialect::strictAssemblyForEVMObjects(evmVersion, eofVersion) : EVMDialect::strictAssemblyForEVM(evmVersion, eofVersion);
	}

	friend std::ostream& operator<<(std::ostream& _out, EVMDialectConfigurationToTest const& _config)
	{
		_out << fmt::format(
			"EVMConfigurationToTest[{}, eof={}, objectAccess={}]",
			_config.evmVersion.name(),
			_config.eofVersion.has_value() ? std::to_string(*_config.eofVersion) : "null",
			_config.objectAccess
		);
		return _out;
	}

	langutil::EVMVersion evmVersion;
	std::optional<uint8_t> eofVersion;
	bool objectAccess;
};

template<ranges::range EVMVersionCollection>
std::vector<EVMDialectConfigurationToTest> generateConfigs(EVMVersionCollection const& _evmVersions, std::vector<bool> const& _objectAccess = {false, true})
{
	std::vector<EVMDialectConfigurationToTest> configs;
	for (bool const objectAccess: _objectAccess)
		for (auto const& eofVersion: langutil::EVMVersion::allEOFVersions())
			for (auto const& evmVersion: _evmVersions)
				if (!eofVersion || evmVersion.supportsEOF())
					configs.push_back(EVMDialectConfigurationToTest{evmVersion, eofVersion, objectAccess});

	return configs;
}
}

BOOST_AUTO_TEST_SUITE(EVMDialectCompatibility)

/// Test for both current and latest (source) EVM dialect that for all other (target) dialects and all builtins in the
/// source dialect, if the builtin exists for both source and target, they have the same handle.
/// Note: The comparison is packed into a single BOOST_REQUIRE to avoid massive amounts of output on cout.
BOOST_DATA_TEST_CASE(
	builtin_function_handle_compatibility,
	bdata::monomorphic::grid(
		bdata::make(generateConfigs(std::array{langutil::EVMVersion::current(), langutil::EVMVersion::allVersions().back()})),
		bdata::make(generateConfigs(langutil::EVMVersion::allVersions()))
	),
	sourceDialectConfiguration,
	evmDialectConfigurationToTest
)
{
	auto const& sourceDialect = sourceDialectConfiguration.dialect();
	auto const& dialectToTestAgainst = evmDialectConfigurationToTest.dialect();

	std::set<std::string_view> const builtinNames = sourceDialect.builtinFunctionNames();
	std::vector<BuiltinHandle> sourceHandles;
	sourceHandles.reserve(builtinNames.size());
	std::vector<std::optional<BuiltinHandle>> testHandles;
	testHandles.reserve(builtinNames.size());

	for (auto const& builtinFunctionName: builtinNames)
	{
		std::optional<BuiltinHandle> sourceHandle = sourceDialect.findBuiltin(builtinFunctionName);
		soltestAssert(sourceHandle.has_value());
		sourceHandles.push_back(*sourceHandle);
		testHandles.push_back(dialectToTestAgainst.findBuiltin(builtinFunctionName));
	}

	BOOST_REQUIRE([&]() -> boost::test_tools::predicate_result
	{
		boost::test_tools::predicate_result result{true};
		for (auto const& [name, sourceBuiltin, testBuiltin]: ranges::views::zip(builtinNames, sourceHandles, testHandles))
			if (testBuiltin && sourceBuiltin != *testBuiltin)
			{
				result = false;
				result.message() << fmt::format("Builtin \"{}\" had a mismatch of builtin handles: {} =/= {}.", name, sourceBuiltin.id, testBuiltin->id);
			}
		return result;
	}());
}

/// Test that for all inline-dialects the corresponding object dialect contains all inline-dialect builtins and they
/// have the same handle.
BOOST_DATA_TEST_CASE(
	builtin_inline_to_object_compatibility,
	bdata::make(generateConfigs(langutil::EVMVersion::allVersions(), {false})),
	configToTest
)
{
	auto const& dialect = EVMDialect::strictAssemblyForEVM(configToTest.evmVersion, configToTest.eofVersion);
	auto const& dialectForObjects = EVMDialect::strictAssemblyForEVMObjects(configToTest.evmVersion, configToTest.eofVersion);

	std::set<std::string_view> const inlineBuiltinNames = dialect.builtinFunctionNames();

	std::vector<BuiltinHandle> inlineHandles;
	inlineHandles.reserve(inlineBuiltinNames.size());
	std::vector<std::optional<BuiltinHandle>> objectHandles;
	objectHandles.reserve(inlineBuiltinNames.size());

	for (auto const& builtinFunctionName: inlineBuiltinNames)
	{
		std::optional<BuiltinHandle> handle = dialect.findBuiltin(builtinFunctionName);
		soltestAssert(handle.has_value());
		inlineHandles.push_back(*handle);
		objectHandles.push_back(dialectForObjects.findBuiltin(builtinFunctionName));
	}

	BOOST_REQUIRE([&]() -> boost::test_tools::predicate_result
	{
		boost::test_tools::predicate_result result{true};
		for (auto const& [name, inlineHandle, objectHandle]: ranges::views::zip(inlineBuiltinNames, inlineHandles, objectHandles))
			if (!objectHandle || inlineHandle != *objectHandle)
			{
				result = false;
				result.message()
					<< fmt::format("Builtin \"{}\" had a mismatch of builtin handles: {} != ", name, inlineHandle.id)
					<< (objectHandle.has_value() ? std::to_string(objectHandle->id) : "null");
			}
		return result;
	}());
}

BOOST_AUTO_TEST_SUITE_END()
