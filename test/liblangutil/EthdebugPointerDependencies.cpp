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

#include <libsolutil/JSON.h>

#include <boost/test/unit_test.hpp>

#include <set>
#include <string>

using namespace solidity;
using namespace solidity::langutil::ethdebug;

namespace
{

void checkPointerDependencies(
	Json const& _pointer,
	std::set<std::string> const& _expectedFreeNames,
	Json const& _templates = Json::object()
)
{
	auto const templates = schema::info::pointersFromJSON(_templates, "templates");
	auto const pointer = schema::pointerFromJSON(_pointer, "pointer", {.internalExpressions = true});
	std::set<std::string> const freeNames = schema::freeNames(pointer, templates);
	BOOST_CHECK_EQUAL_COLLECTIONS(freeNames.begin(), freeNames.end(), _expectedFreeNames.begin(), _expectedFreeNames.end());
}

}

BOOST_AUTO_TEST_SUITE(EthdebugPointerDependencies)

BOOST_AUTO_TEST_CASE(pointer_definitions_bind_in_order)
{
	checkPointerDependencies(Json::parse(R"({
    "define": {"a": "0x01"},
    "in": {
        "define": {"b": {"~sum": ["a", "0x01"]}},
        "in": {"location": "storage", "slot": "b"}
    }
})"), {});
	// A later definition must not bind an earlier initializer or its own initializer.
	checkPointerDependencies(Json::parse(R"({
    "define": {"a": "b"},
    "in": {
        "define": {"b": "0x01"},
        "in": {"location": "storage", "slot": "a"}
    }
})"), {"b"});
	checkPointerDependencies(Json::parse(R"({
    "define": {"a": "a"},
    "in": {"location": "storage", "slot": "a"}
})"), {"a"});
}

BOOST_AUTO_TEST_CASE(pointer_variable_bindings_do_not_escape)
{
	checkPointerDependencies(Json::parse(R"({
    "group": [
        {
            "define": {"a": "0x01"},
            "in": {
                "define": {"a": {"~sum": ["a", "0x01"]}},
                "in": {"location": "storage", "slot": "a"}
            }
        },
        {
            "list": {
                "count": "0x01",
                "each": "index",
                "is": {"location": "storage", "slot": "index"}
            }
        },
        {"location": "storage", "slot": "a"},
        {"location": "storage", "slot": "index"}
    ]
})"), {"a", "index"});
}

BOOST_AUTO_TEST_CASE(pointer_local_templates_shadow_outer_definitions)
{
	checkPointerDependencies(Json::parse(R"({
    "templates": {
        "T": {"expect": [], "for": {"location": "storage", "slot": "outer"}}
    },
    "in": {
        "templates": {
            "T": {"expect": [], "for": {"location": "storage", "slot": "0x00"}}
        },
        "in": {"template": "T"}
    }
})"), {});
	// Leaving the inner block restores the outer template.
	checkPointerDependencies(Json::parse(R"({
    "templates": {
        "T": {"expect": [], "for": {"location": "storage", "slot": "outer"}}
    },
    "in": {
        "group": [
            {
                "templates": {
                    "T": {"expect": [], "for": {"location": "storage", "slot": "0x00"}}
                },
                "in": {"template": "T"}
            },
            {"template": "T"}
        ]
    }
})"), {"outer"});
}

BOOST_AUTO_TEST_CASE(pointer_template_arguments_must_be_bound)
{
	checkPointerDependencies(Json::parse(R"({
    "templates": {
        "T": {"expect": ["slot"], "for": {"location": "storage", "slot": "slot"}}
    },
    "in": {"template": "T"}
})"), {"slot"});
	Json const templates = Json::parse(R"({
    "T": {"expect": ["slot", "unused"], "for": {"location": "storage", "slot": "slot"}}
})");
	checkPointerDependencies(Json::parse(R"({"template": "T"})"), {"slot", "unused"}, templates);
	// All expected arguments are required, even one the template body does not read.
	checkPointerDependencies(Json::parse(R"({
    "define": {"slot": "0x00"},
    "in": {"template": "T"}
})"), {"unused"}, templates);
	checkPointerDependencies(Json::parse(R"({
    "define": {"slot": "0x00", "unused": "0x01"},
    "in": {"template": "T"}
})"), {}, templates);
}

BOOST_AUTO_TEST_CASE(pointer_template_dependencies_follow_local_templates)
{
	Json const templates = Json::parse(R"({
    "T": {"expect": [], "for": {"template": "U"}},
    "U": {"expect": [], "for": {"location": "storage", "slot": "global"}}
})");
	checkPointerDependencies(Json::parse(R"({
    "group": [
        {
            "templates": {
                "U": {"expect": [], "for": {"location": "storage", "slot": "0x00"}}
            },
            "in": {"template": "T"}
        },
        {"template": "T"}
    ]
})"), {"global"}, templates);
}

BOOST_AUTO_TEST_CASE(recursive_pointer_templates_keep_dependencies)
{
	Json const templates = Json::parse(R"({
    "A": {
        "expect": [],
        "for": {
            "group": [
                {"template": "B"},
                {"location": "storage", "slot": "x"}
            ]
        }
    },
    "B": {"expect": [], "for": {"template": "A"}}
})");
	checkPointerDependencies(Json::parse(R"({
    "group": [
        {"define": {"x": "0x00"}, "in": {"template": "A"}},
        {"template": "B"}
    ]
})"), {"x"}, templates);
	checkPointerDependencies(Json::parse(R"({
    "define": {"x": "0x00"},
    "in": {"template": "A"}
})"), {}, templates);
}

BOOST_AUTO_TEST_CASE(recursive_templates_use_current_local_definitions)
{
	Json const templates = Json::parse(R"({
    "T": {
        "expect": [],
        "for": {
            "group": [
                {"template": "U"},
                {
                    "templates": {
                        "U": {"expect": [], "for": {"location": "storage", "slot": "missing"}}
                    },
                    "in": {"template": "T"}
                }
            ]
        }
    },
    "U": {"expect": [], "for": {"location": "storage", "slot": "0x00"}}
})");
	checkPointerDependencies(Json::parse(R"({"template": "T"})"), {"missing"}, templates);
}

BOOST_AUTO_TEST_CASE(pointer_bindings_cannot_bind_internal_yul_locals)
{
	checkPointerDependencies(Json::parse(R"({
    "define": {"local": "0x00"},
    "in": {
        "templates": {
            "T": {"expect": [], "for": {"location": "stack", "slot": {"~~yulLocal": "local"}}}
        },
        "in": {"template": "T"}
    }
})"), {"local"});
}

BOOST_AUTO_TEST_SUITE_END()
