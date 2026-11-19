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
 * Unit tests for the logging registry.
 */

#include <libsolutil/Logger.h>

#include <boost/test/unit_test.hpp>

#include <algorithm>
#include <optional>
#include <regex>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

using namespace solidity::log;

namespace solidity::log::test
{

namespace
{

DEFINE_LOGGER(staticLogger, "test.logger.static_registration");

static_assert(isValidCategory("yul"));
static_assert(isValidCategory("yul.ssa.codetransform"));
static_assert(isValidCategory("a0_-.b-9_"));
static_assert(!isValidCategory(""));
static_assert(!isValidCategory("."));
static_assert(!isValidCategory("yul."));
static_assert(!isValidCategory(".yul"));
static_assert(!isValidCategory("yul..ssa"));
static_assert(!isValidCategory("Yul"));
static_assert(!isValidCategory("yul ssa"));
static_assert(!isValidCategory("yul/ssa"));

/// Resets the registry before and after each test so the process-wide singleton stays isolated.
struct LoggerFixture
{
	LoggerFixture() { LoggerRegistry::singleton().reset(); }
	~LoggerFixture() { LoggerRegistry::singleton().reset(); }
};

}

BOOST_FIXTURE_TEST_SUITE(LoggerTest, LoggerFixture)

BOOST_AUTO_TEST_CASE(is_valid_category_agrees_with_regex)
{
	std::regex const categoryPattern(R"([a-z0-9_-]+(\.[a-z0-9_-]+)*)");
	auto check = [&](std::string const& _category) {
		bool const matchesRegex = std::regex_match(_category, categoryPattern);
		BOOST_CHECK_MESSAGE(
			isValidCategory(_category) == matchesRegex,
			"isValidCategory(\"" + _category + "\") disagrees with the regex, which " +
			(matchesRegex ? "accepts" : "rejects") + " it"
		);
	};

	for (std::string const category: {
		"yul",
		"yul.ssa.codetransform.shuffler",
		"evmasm.peephole-optimiser",
		"a_b-c.0.9",
		"yul.ssa2",
		"yul..ssa",
		"yul.ssa.",
		".yul.ssa",
		"Yul.ssa",
		"yul.SSA",
		"yul:ssa",
		"yul\tssa",
		"yül",
	})
		check(category);

	// Every string of length up to 4 over the valid characters, the separator and the nearest invalid
	// neighbour of each character range.
	std::string const alphabet = "az09_-.`{/:A ";
	size_t const maxLength = 4;
	std::vector<std::string> current{""};
	for (size_t length = 0; length <= maxLength; ++length)
	{
		std::vector<std::string> next;
		for (std::string const& prefix: current)
		{
			check(prefix);
			if (length < maxLength)
				for (char const c: alphabet)
					next.push_back(prefix + c);
		}
		current = std::move(next);
	}
}

BOOST_AUTO_TEST_CASE(loggers_default_to_off)
{
	Logger const& logger = LoggerRegistry::singleton().get("yul.ssa");
	for (Level level = 0; level <= maxLevel; ++level)
		BOOST_CHECK(!logger.shouldLog(level));
}

BOOST_AUTO_TEST_CASE(higher_level_is_more_verbose)
{
	auto& registry = LoggerRegistry::singleton();
	Logger const& logger = registry.get("a");

	registry.setLevel("a", 1);
	BOOST_CHECK(logger.shouldLog(1));
	BOOST_CHECK(!logger.shouldLog(2));
	BOOST_CHECK(!logger.shouldLog(3));

	registry.setLevel("a", 2);
	BOOST_CHECK(logger.shouldLog(1));
	BOOST_CHECK(logger.shouldLog(2));
	BOOST_CHECK(!logger.shouldLog(3));

	registry.setLevel("a", 3);
	BOOST_CHECK(logger.shouldLog(1));
	BOOST_CHECK(logger.shouldLog(2));
	BOOST_CHECK(logger.shouldLog(3));

	registry.setLevel("a", 0);
	BOOST_CHECK(!logger.shouldLog(1));
	BOOST_CHECK(!logger.shouldLog(2));
	BOOST_CHECK(!logger.shouldLog(3));
}

BOOST_AUTO_TEST_CASE(level_zero_messages_are_never_logged)
{
	auto& registry = LoggerRegistry::singleton();
	Logger const& logger = registry.get("a");
	registry.setLevel("a", maxLevel);
	BOOST_CHECK(!logger.shouldLog(0));
}

BOOST_AUTO_TEST_CASE(prefix_matches_whole_components)
{
	BOOST_CHECK(prefixMatches("yul.ssa", "yul.ssa"));
	BOOST_CHECK(prefixMatches("yul.ssa", "yul.ssa.codetransform"));
	BOOST_CHECK(prefixMatches("yul", "yul.ssa.codetransform"));
	BOOST_CHECK(!prefixMatches("yul.ssa", "yul.ssa2"));
	BOOST_CHECK(!prefixMatches("yul.ss", "yul.ssa"));
	BOOST_CHECK(!prefixMatches("yul.ssa.codetransform", "yul.ssa"));
	BOOST_CHECK(!prefixMatches("ssa", "yul.ssa"));
	BOOST_CHECK(prefixMatches("", "yul"));
	BOOST_CHECK(prefixMatches("", "yul.ssa"));
}

BOOST_AUTO_TEST_CASE(longest_matching_prefix_wins)
{
	auto& registry = LoggerRegistry::singleton();
	// Spec example: the global default is set last and does not override the more specific rules.
	registry.setLevel("yul.ssa", 2);
	registry.setLevel("yul.ssa.codetransform.shuffler", 0);
	registry.setLevel("", 1);

	BOOST_CHECK(registry.get("yul").shouldLog(1));
	BOOST_CHECK(!registry.get("yul").shouldLog(2));

	BOOST_CHECK(registry.get("yul.ssa").shouldLog(2));
	BOOST_CHECK(registry.get("yul.ssa.codetransform").shouldLog(2));
	BOOST_CHECK(!registry.get("yul.ssa.codetransform").shouldLog(3));

	BOOST_CHECK(!registry.get("yul.ssa.codetransform.shuffler").shouldLog(1));
	BOOST_CHECK(!registry.get("yul.ssa.codetransform.shuffler.detail").shouldLog(1));

	// Not a whole-component match of "yul.ssa", so only the global default applies.
	BOOST_CHECK(registry.get("yul.ssa2").shouldLog(1));
	BOOST_CHECK(!registry.get("yul.ssa2").shouldLog(2));
}

BOOST_AUTO_TEST_CASE(result_does_not_depend_on_rule_order)
{
	auto& registry = LoggerRegistry::singleton();
	std::vector<std::pair<std::string, Level>> rules = {
		{"", 1},
		{"yul", 3},
		{"yul.ssa", 2},
		{"yul.ssa.codetransform.shuffler", 0},
	};
	std::vector<std::string> const categories = {
		"evmasm",
		"yul",
		"yul.opt",
		"yul.ssa",
		"yul.ssa.codetransform",
		"yul.ssa.codetransform.shuffler",
	};

	auto levels = [&]() {
		std::vector<Level> result;
		for (std::string const& category: categories)
		{
			Level level = 0;
			while (level < maxLevel && registry.get(category).shouldLog(static_cast<Level>(level + 1)))
				++level;
			result.push_back(level);
		}
		return result;
	};

	std::sort(rules.begin(), rules.end());
	std::optional<std::vector<Level>> expected;
	do
	{
		registry.reset();
		for (auto const& [prefix, level]: rules)
			registry.setLevel(prefix, level);
		if (!expected)
			expected = levels();
		else
			BOOST_CHECK(levels() == *expected);
	}
	while (std::next_permutation(rules.begin(), rules.end()));

	BOOST_CHECK((*expected == std::vector<Level>{1, 3, 3, 2, 2, 0}));
}

BOOST_AUTO_TEST_CASE(set_level_replaces_rule_for_same_prefix)
{
	auto& registry = LoggerRegistry::singleton();
	Logger const& logger = registry.get("yul.ssa");
	registry.setLevel("yul", 3);
	registry.setLevel("yul", 1);
	BOOST_CHECK(logger.shouldLog(1));
	BOOST_CHECK(!logger.shouldLog(2));
}

BOOST_AUTO_TEST_CASE(level_change_propagates_to_existing_loggers)
{
	auto& registry = LoggerRegistry::singleton();
	Logger const& logger = registry.get("yul.ssa.stacklayout");
	BOOST_CHECK(!logger.shouldLog(1));

	registry.setLevel("yul.ssa", 1);
	BOOST_CHECK(logger.shouldLog(1));
}

BOOST_AUTO_TEST_CASE(new_logger_picks_up_existing_rules)
{
	auto& registry = LoggerRegistry::singleton();
	registry.setLevel("yul.ssa", 2);
	BOOST_CHECK(registry.get("yul.ssa.created_after_rule").shouldLog(2));
}

BOOST_AUTO_TEST_CASE(define_logger_registers_during_static_initialisation)
{
	auto& registry = LoggerRegistry::singleton();
	std::vector<std::string> const categories = registry.categories();
	BOOST_CHECK(std::is_sorted(categories.begin(), categories.end()));
	BOOST_CHECK(std::find(categories.begin(), categories.end(), "test.logger.static_registration") != categories.end());

	BOOST_CHECK(registry.matchesAnyCategory(""));
	BOOST_CHECK(registry.matchesAnyCategory("test"));
	BOOST_CHECK(registry.matchesAnyCategory("test.logger"));
	BOOST_CHECK(registry.matchesAnyCategory("test.logger.static_registration"));
	BOOST_CHECK(!registry.matchesAnyCategory("test.log"));
	BOOST_CHECK(!registry.matchesAnyCategory("test.logger.static_registration.child"));

	BOOST_CHECK(!staticLogger.shouldLog(1));
	registry.setLevel("test.logger", 1);
	BOOST_CHECK(staticLogger.shouldLog(1));
}

BOOST_AUTO_TEST_CASE(output_has_time_level_and_category_prefix)
{
	auto& registry = LoggerRegistry::singleton();
	std::ostringstream out;
	registry.setOutput(out);
	registry.setLevel("c", 1);

	Logger const& logger = registry.get("c");
	solLog1(logger, "step={} removed={}", "CSE", 42);
	// "[<seconds, width 8, 3 decimals>s L<level> <category>] <message>\n"
	BOOST_CHECK_MESSAGE(
		std::regex_match(out.str(), std::regex(R"(\[[ 0-9]{3}[0-9]\.[0-9]{3}s L1 c\] step=CSE removed=42\n)")),
		out.str()
	);
}

BOOST_AUTO_TEST_CASE(prefix_carries_message_level_not_logger_level)
{
	auto& registry = LoggerRegistry::singleton();
	std::ostringstream out;
	registry.setOutput(out);
	registry.setLevel("yul.ssa", 3);

	Logger const& logger = registry.get("yul.ssa");
	solLog2(logger, "x");
	solLog3(logger, "y");
	BOOST_CHECK_MESSAGE(
		std::regex_match(out.str(), std::regex(R"(\[[ 0-9.]{8}s L2 yul\.ssa\] x\n\[[ 0-9.]{8}s L3 yul\.ssa\] y\n)")),
		out.str()
	);
}

BOOST_AUTO_TEST_CASE(messages_above_logger_level_are_dropped)
{
	auto& registry = LoggerRegistry::singleton();
	std::ostringstream out;
	registry.setOutput(out);
	registry.setLevel("c", 1);

	Logger const& logger = registry.get("c");
	solLog2(logger, "dropped");
	solLog3(logger, "dropped");
	BOOST_CHECK(out.str().empty());
}

BOOST_AUTO_TEST_CASE(disabled_logger_does_not_evaluate_arguments)
{
	auto& registry = LoggerRegistry::singleton();
	std::ostringstream out;
	registry.setOutput(out);

	Logger const& logger = registry.get("d"); // defaults to off

	int evaluations = 0;
	auto sideEffect = [&]() { ++evaluations; return 42; };

	solLog1(logger, "{}", sideEffect());
	BOOST_CHECK_EQUAL(evaluations, 0);
	BOOST_CHECK(out.str().empty());

	registry.setLevel("d", 1);
	solLog1(logger, "{}", sideEffect());
	BOOST_CHECK_EQUAL(evaluations, 1);
	BOOST_CHECK(out.str().ends_with("L1 d] 42\n"));
}

BOOST_AUTO_TEST_CASE(reset_turns_everything_off)
{
	auto& registry = LoggerRegistry::singleton();
	Logger const& logger = registry.get("c");
	registry.setLevel("", 3);
	BOOST_CHECK(logger.shouldLog(3));

	registry.reset();
	BOOST_CHECK(!logger.shouldLog(1));
	// Rules are gone too, so new loggers start off.
	BOOST_CHECK(!registry.get("c.child").shouldLog(1));
}

BOOST_AUTO_TEST_SUITE_END()

}
