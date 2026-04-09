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
 * Performance tests for VarNameCleaner to verify O(n) behaviour
 * when many variables share the same stripped base name.
 */

#include <test/Common.h>
#include <test/libyul/Common.h>

#include <libyul/optimiser/VarNameCleaner.h>
#include <libyul/optimiser/Disambiguator.h>
#include <libyul/optimiser/FunctionGrouper.h>
#include <libyul/optimiser/FunctionHoister.h>
#include <libyul/optimiser/NameDispenser.h>
#include <libyul/AST.h>
#include <libyul/Object.h>
#include <libyul/YulStack.h>
#include <libyul/Dialect.h>
#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/optimiser/OptimiserStep.h>

#include <boost/test/unit_test.hpp>

#include <chrono>
#include <sstream>
#include <string>

using namespace solidity::langutil;

namespace solidity::yul::test
{

namespace
{

/// Build a Yul block with @a n variables all sharing the same base name "x":
///   { let x_100 := 1  let x_200 := 2  ...  let x_(n*100) := n }
/// Using large suffix gaps so stripSuffix strips them all to "x".
std::string buildManyVarsYul(size_t n)
{
	std::ostringstream src;
	src << "{\n";
	for (size_t i = 1; i <= n; ++i)
		src << "  let x_" << (i * 100) << " := " << i << "\n";
	src << "}\n";
	return src.str();
}

/// Run VarNameCleaner on the given Yul source and return the elapsed time.
std::chrono::microseconds runVarNameCleaner(std::string const& _source)
{
	auto block = disambiguate(_source);
	Dialect const& d = EVMDialect::strictAssemblyForEVMObjects(EVMVersion{}, std::nullopt);
	std::set<YulName> reserved;
	NameDispenser dispenser(d, block, reserved);
	OptimiserStepContext context{d, dispenser, reserved, 0};
	FunctionHoister::run(context, block);
	FunctionGrouper::run(context, block);

	auto start = std::chrono::high_resolution_clock::now();
	VarNameCleaner::run(context, block);
	auto end = std::chrono::high_resolution_clock::now();

	return std::chrono::duration_cast<std::chrono::microseconds>(end - start);
}

}

BOOST_AUTO_TEST_SUITE(YulVarNameCleanerPerf)

// Verify that VarNameCleaner scales linearly, not quadratically.
// We compare the runtime of N=2000 vs N=500.  With the old O(n^2) code
// the ratio would be ~16x; with the fix it should be close to 4x (linear).
// We use a generous 8x threshold to avoid flaky failures.
BOOST_AUTO_TEST_CASE(linear_scaling)
{
	size_t const smallN = 500;
	size_t const largeN = 2000;

	std::string smallSrc = buildManyVarsYul(smallN);
	std::string largeSrc = buildManyVarsYul(largeN);

	// Warm up
	runVarNameCleaner(smallSrc);

	auto smallTime = runVarNameCleaner(smallSrc);
	auto largeTime = runVarNameCleaner(largeSrc);

	// With O(n) scaling and n ratio of 4x, we expect time ratio ~4x.
	// With O(n^2), the ratio would be ~16x.
	// Allow up to 8x to avoid flaky test failures while still catching quadratic.
	double ratio = static_cast<double>(largeTime.count()) /
		static_cast<double>(std::max(smallTime.count(), decltype(smallTime.count()){1}));

	BOOST_TEST_MESSAGE("VarNameCleaner: N=" << smallN << " took " << smallTime.count() << " us");
	BOOST_TEST_MESSAGE("VarNameCleaner: N=" << largeN << " took " << largeTime.count() << " us");
	BOOST_TEST_MESSAGE("Ratio: " << ratio << "x (expected ~4x for linear, ~16x for quadratic)");

	BOOST_CHECK_MESSAGE(ratio < 8.0,
		"VarNameCleaner appears to scale worse than linearly: "
		"ratio=" << ratio << "x for " << largeN << "/" << smallN << " variables. "
		"Expected <8x for O(n), got " << ratio << "x."
	);
}

BOOST_AUTO_TEST_SUITE_END()

}
