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
 * Unit tests for SSA stack utility helpers.
 */

#include <liblangutil/Exceptions.h>

#include <libyul/backends/evm/ssa/SSACFG.h>
#include <libyul/backends/evm/ssa/StackShuffler.h>
#include <libyul/backends/evm/ssa/StackUtils.h>

#include <boost/test/unit_test.hpp>

using namespace solidity::langutil;
using namespace solidity::yul::ssa;

namespace solidity::yul::ssa::test
{

namespace
{

std::string errorMessage(util::Exception const& _exception)
{
	return _exception.comment() ? *_exception.comment() : "";
}

StackSlot makeVariable(unsigned _id)
{
	return StackSlot::makeValueID(SSACFG::ValueId::makeVariable(_id));
}

}

BOOST_AUTO_TEST_SUITE(StackUtilsTest)

BOOST_AUTO_TEST_CASE(requireAdmissibleShuffle_throws_stack_too_deep_error)
{
	StackShufflerResult const stackTooDeepResult{
		.status = StackShufflerResult::Status::StackTooDeep,
		.culprit = makeVariable(7)
	};
	BOOST_CHECK_EXCEPTION(
		requireAdmissibleShuffle(
			"SSA test shuffle",
			stackTooDeepResult,
			"source stack [v1]"
		),
		langutil::StackTooDeepError,
		[](langutil::StackTooDeepError const& _exception)
		{
			BOOST_TEST(
				errorMessage(_exception) ==
				"SSA test shuffle failed with StackTooDeep (culprit: v7): source stack [v1]"
			);
			return true;
		}
	);
}

BOOST_AUTO_TEST_CASE(requireAdmissibleShuffle_throws_internal_compiler_error_for_max_iterations)
{
	StackShufflerResult const maxIterationsResult{.status = StackShufflerResult::Status::MaxIterationsReached};
	BOOST_CHECK_EXCEPTION(
		requireAdmissibleShuffle(
			"SSA test shuffle",
			maxIterationsResult,
			"target size 17"
		),
		InternalCompilerError,
		[](InternalCompilerError const& _exception)
		{
			BOOST_TEST(errorMessage(_exception) == "SSA test shuffle failed with MaxIterationsReached: target size 17");
			return true;
		}
	);
}

BOOST_AUTO_TEST_CASE(requireAdmissibleShuffle_throws_internal_compiler_error_for_continue)
{
	StackShufflerResult const continueResult{.status = StackShufflerResult::Status::Continue};
	BOOST_CHECK_EXCEPTION(
		requireAdmissibleShuffle(
			"SSA test shuffle",
			continueResult,
			"target size 23"
		),
		InternalCompilerError,
		[](InternalCompilerError const& _exception)
		{
			BOOST_TEST(errorMessage(_exception) == "SSA test shuffle failed with Continue: target size 23");
			return true;
		}
	);
}

BOOST_AUTO_TEST_SUITE_END()

}
