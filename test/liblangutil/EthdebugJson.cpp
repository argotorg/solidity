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

#include <liblangutil/EthdebugJson.h>

#include <boost/test/unit_test.hpp>

#include <functional>
#include <string>
#include <utility>
#include <vector>

namespace solidity::langutil::test
{

using namespace ethdebug;

BOOST_AUTO_TEST_SUITE(EthdebugJson)

BOOST_AUTO_TEST_CASE(valid_values)
{
	Json const object = {
		{"items", Json::array()},
		{"name", "value"},
		{"nullValue", nullptr},
		{"zero", 0},
	};
	BOOST_CHECK_NO_THROW(requireObject(object, "root"));
	BOOST_CHECK_NO_THROW(requireArray(object.at("items"), "root.items"));
	BOOST_CHECK_NO_THROW(requireOnlyMembers(object, {"items", "name", "nullValue", "zero"}, "root"));
	BOOST_CHECK(&requireMember(object, "name", "root") == &object.at("name"));
	BOOST_CHECK(checkAndFindMember(object, "nullValue", "root") == &object.at("nullValue"));
	BOOST_CHECK(checkAndFindMember(object, "missing", "root") == nullptr);
	BOOST_CHECK_EQUAL(requireMemberOfType<std::string>(object, "name", "root"), "value");
	BOOST_CHECK_EQUAL(checkAndReadOptionalMember<unsigned>(object, "zero", "root").value(), 0);
	BOOST_CHECK(!checkAndReadOptionalMember<unsigned>(object, "missing", "root").has_value());
}

BOOST_AUTO_TEST_CASE(validation_errors)
{
	Json const object = {
		{"name", nullptr},
		{"negative", -1},
		{"zero", 0},
	};
	Json const array = Json::array();
	std::vector<std::pair<std::function<void()>, std::string>> const cases{
		{[&] { requireObject(array, "root"); }, "root: expected object."},
		{[&] { requireArray(object, "root"); }, "root: expected array."},
		{[&] { requireOnlyMembers(object, {"negative", "zero"}, "root"); }, "root has an unknown member \"name\"."},
		{[&] { requireMember(object, "missing", "root"); }, "root.missing is required."},
		{[&] { checkAndFindMember(array, "missing", "root"); }, "root: expected object."},
		{[&] { requireValueOfType<std::string>(object, "root"); }, "root: expected string."},
		{[&] { requireValueOfType<bool>(object, "root"); }, "root: expected boolean."},
		{[&] { requireValueOfType<double>(object, "root"); }, "root: expected number."},
		{[&] { requireValueOfType<int>(object, "root"); }, "root: expected integer."},
		{[&] { requireMemberOfType<unsigned>(object, "negative", "root"); }, "root.negative: expected unsigned integer."},
		{[&] { requireMemberOfType<std::string>(object, "zero", "root"); }, "root.zero: expected string."},
		{[&] { checkAndReadOptionalMember<std::string>(object, "zero", "root"); }, "root.zero: expected string."},
		{[&] { checkAndReadOptionalMember<std::string>(object, "name", "root"); }, "root.name: expected string."},
	};

	for (auto const& [validate, message]: cases)
		BOOST_TEST_CONTEXT(message)
			BOOST_CHECK_EXCEPTION(validate(), JsonValidationError, [&](JsonValidationError const& _error) {
				return _error.comment() != nullptr && *_error.comment() == message;
			});
}

BOOST_AUTO_TEST_SUITE_END()

}
