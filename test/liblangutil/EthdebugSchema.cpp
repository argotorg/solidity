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

#include <liblangutil/EthdebugSchema.h>

#include <boost/test/unit_test.hpp>

using namespace solidity;
using namespace solidity::langutil::ethdebug::schema;

BOOST_AUTO_TEST_SUITE(EthdebugSchema)

BOOST_AUTO_TEST_CASE(define_resolves_dependencies_before_their_users)
{
	Json const input = Json::parse(R"({
    "define": {"offset": 64},
    "in": {
        "define": {
            "end": {"~sum": ["middle", "~wordsize"]},
            "middle": {"~sum": ["offset", 32]},
            "offset": {"~sum": ["offset", 32]}
        },
        "in": {"location": "memory", "offset": "offset", "length": "end"}
    }
})");

	Pointer const pointer = pointerFromJSON(input, "pointer");
	auto const& outer = std::get<Pointer::Scope>(pointer.value);
	BOOST_REQUIRE_EQUAL(outer.definitions.size(), 1);
	BOOST_CHECK_EQUAL(outer.definitions.at(0).first, "offset");

	auto const& inner = std::get<Pointer::Scope>(outer.in->value);
	BOOST_REQUIRE_EQUAL(inner.definitions.size(), 3);
	BOOST_CHECK_EQUAL(inner.definitions.at(0).first, "offset");
	BOOST_CHECK_EQUAL(inner.definitions.at(1).first, "middle");
	BOOST_CHECK_EQUAL(inner.definitions.at(2).first, "end");

	// Inner offset reads the enclosing offset, not itself.
	auto const& sum = std::get<Pointer::Arithmetic>(inner.definitions.at(0).second.value);
	BOOST_CHECK_EQUAL(std::get<Pointer::Variable>(sum.operands.at(0).value).identifier, "offset");

	// The writer keeps the original scope boundaries and sibling bindings.
	BOOST_CHECK(Json(pointer) == input);
}

BOOST_AUTO_TEST_SUITE_END()
