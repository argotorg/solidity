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
 * @author Yoichi Hirai <yoichi@ethereum.org>
 * @date 2016
 * Unit tests for the SourceLocation class.
 */

#include <liblangutil/Exceptions.h>
#include <liblangutil/SourceLocation.h>

#include <test/Common.h>

#include <boost/test/unit_test.hpp>

namespace solidity::langutil::test
{

BOOST_AUTO_TEST_SUITE(SourceLocationTest)

BOOST_AUTO_TEST_CASE(test_fail)
{
	auto const source = std::make_shared<std::string>("source");
	auto const sourceA = std::make_shared<std::string>("sourceA");
	auto const sourceB = std::make_shared<std::string>("sourceB");

	BOOST_CHECK(SourceLocation{} == SourceLocation{});
	BOOST_CHECK((SourceLocation{0, 3, sourceA} != SourceLocation{0, 3, sourceB}));
	BOOST_CHECK((SourceLocation{0, 3, source} == SourceLocation{0, 3, source}));
	BOOST_CHECK((SourceLocation{3, 7, source}.contains(SourceLocation{4, 6, source})));
	BOOST_CHECK((!SourceLocation{3, 7, sourceA}.contains(SourceLocation{4, 6, sourceB})));
	BOOST_CHECK((SourceLocation{3, 7, sourceA} < SourceLocation{4, 6, sourceB}));
}

BOOST_AUTO_TEST_CASE(parse_source_location_rejects_malformed_fields)
{
	std::vector<std::shared_ptr<std::string const>> const sourceNames{std::make_shared<std::string const>("A")};
	for (std::string const input: {"+5:0:0", " 5:0:0", "0x10:0:0", "1e5:0:0", "abc:0:0", "99999999999999999999:0:0", "2147483647:1:0", "1:2"})
		BOOST_CHECK_THROW(parseSourceLocation(input, sourceNames), InvalidAstError);
}

BOOST_AUTO_TEST_CASE(parse_source_location_accepts_decimal_fields)
{
	std::vector<std::shared_ptr<std::string const>> const sourceNames{std::make_shared<std::string const>("A")};
	SourceLocation const location = parseSourceLocation("32:23:0", sourceNames);
	BOOST_CHECK_EQUAL(location.start, 32);
	BOOST_CHECK_EQUAL(location.end, 55);
	BOOST_REQUIRE(location.sourceName);
	BOOST_CHECK_EQUAL(*location.sourceName, "A");
	SourceLocation const unknown = parseSourceLocation("-1:-1:-1", sourceNames);
	BOOST_CHECK_EQUAL(unknown.start, -1);
	BOOST_CHECK(!unknown.sourceName);
	BOOST_CHECK_NO_THROW(parseSourceLocation("-0:0:-1", sourceNames));
}

BOOST_AUTO_TEST_SUITE_END()

} // end namespaces
