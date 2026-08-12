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

/// Unit tests for libsolidity/interface/Common.h

#include <libsolidity/interface/MetadataSettings.h>

#include <test/libsolidity/util/SoltestErrors.h>


#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/test/unit_test.hpp>

using namespace solidity::util;

#define TEST_CASE_NAME (boost::unit_test::framework::current_test_case().p_name)

namespace solidity::frontend::test
{

BOOST_AUTO_TEST_SUITE(MetadataSettingsTest)

BOOST_AUTO_TEST_CASE(metadataHashFromString_returns_correct_enum)
{
	BOOST_CHECK(metadataHashFromString("ipfs") == MetadataHash::IPFS);
	BOOST_CHECK(metadataHashFromString("bzzr1") == MetadataHash::Bzzr1);
}

BOOST_AUTO_TEST_CASE(metadataHashFromString_invalid_input_returns_none)
{
	BOOST_CHECK(metadataHashFromString("invalid") == MetadataHash::None);
}

BOOST_AUTO_TEST_CASE(metadataHashToString_returns_correct_string)
{
	BOOST_CHECK_EQUAL(metadataHashToString(MetadataHash::IPFS), "ipfs");
	BOOST_CHECK_EQUAL(metadataHashToString(MetadataHash::Bzzr1), "bzzr1");
	BOOST_CHECK_EQUAL(metadataHashToString(MetadataHash::None), "none");
}

BOOST_AUTO_TEST_SUITE_END()

} // namespace solidity::frontend::test
