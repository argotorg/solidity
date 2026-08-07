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

#include <libsolidity/ast/ASTEnums.h>

#include <test/libsolidity/util/SoltestErrors.h>


#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/test/unit_test.hpp>

using namespace solidity::util;

#define TEST_CASE_NAME (boost::unit_test::framework::current_test_case().p_name)

namespace solidity::frontend::test
{

BOOST_AUTO_TEST_SUITE(ASTEnumsTest)

BOOST_AUTO_TEST_CASE(stateMutabilityFromString_returns_correct_enum)
{
	BOOST_CHECK(stateMutabilityFromString("pure") == StateMutability::Pure);
	BOOST_CHECK(stateMutabilityFromString("view") == StateMutability::View);
	BOOST_CHECK(stateMutabilityFromString("nonpayable") == StateMutability::NonPayable);
	BOOST_CHECK(stateMutabilityFromString("payable") == StateMutability::Payable);
}

BOOST_AUTO_TEST_CASE(stateMutabilityToString_returns_correct_string)
{
	BOOST_CHECK_EQUAL(stateMutabilityToString(StateMutability::Pure), "pure");
	BOOST_CHECK_EQUAL(stateMutabilityToString(StateMutability::View), "view");
	BOOST_CHECK_EQUAL(stateMutabilityToString(StateMutability::NonPayable), "nonpayable");
	BOOST_CHECK_EQUAL(stateMutabilityToString(StateMutability::Payable), "payable");
}
BOOST_AUTO_TEST_SUITE_END()

} // namespace solidity::frontend::test
