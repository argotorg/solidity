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
 * Runtime switchable, hierarchical logging for the compiler developers. Not a user-facing facility:
 * user-relevant errors and warnings go through ErrorReporter.
 *
 * Loggers are named hierarchically with '.' separators, e.g. "yul.ssa.stacklayout". Each logger is
 * registered with LoggerRegistry by DEFINE_LOGGER during static initialisation, so DEFINE_LOGGER must
 * be used at namespace scope. Every logger starts at level 0 (off) until the CLI configures it.
 * Use the solLog1/solLog2/solLog3 macros at the call sites.
 */
#pragma once

#include <fmt/format.h>

#include <chrono>
#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <ostream>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>
#include <vector>

namespace solidity::log
{

/// Log verbosity level: Higher values means more verbose
/// 1: major events and summaries
/// 2: per-function detail and optimizer decisions
/// 3: debug dumps
using Level = std::uint8_t;
constexpr Level maxLevel = 3;

/// @returns true if @a _category matches `[a-z0-9_-]+(\.[a-z0-9_-]+)*`.
constexpr bool isValidCategory(std::string_view _category) noexcept
{
	bool componentEmpty = true;
	for (char const c: _category)
		if (c == '.')
		{
			if (componentEmpty)
				return false;
			componentEmpty = true;
		}
		else if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '-')
			componentEmpty = false;
		else
			return false;
	return !componentEmpty;
}

/// @returns true if @a _prefix matches @a _category on whole '.'-separated components.
/// e.g.: yul.ssa matches both `yul.ssa` and `yul.ssa.codetransform`
/// The empty prefix matches every category.
bool prefixMatches(std::string_view _prefix, std::string_view _category) noexcept;

struct LoggerHandle;

class Logger
{
public:
	Logger(Logger const&) = delete;
	Logger(Logger&&) = delete;
	Logger& operator=(Logger const&) = delete;
	Logger& operator=(Logger&&) = delete;

	bool shouldLog(Level _level) const noexcept { return _level != 0 && _level <= *m_level; }

	template<typename... Args>
	void log(Level _level, fmt::format_string<Args...> _format, Args&&... _args) const
	{
		emitFormatted(_level, fmt::format(_format, std::forward<Args>(_args)...));
	}

private:
	friend struct LoggerHandle;

	Logger(Level const* _level, std::string_view _category) noexcept: m_level(_level), m_category(_category) {}

	void emitFormatted(Level _level, std::string const& _message) const;

	/// Points to the effective level cached in the LoggerHandle owned by the registry.
	Level const* m_level = nullptr;
	std::string_view m_category;
};

/// Process-wide singleton registry of loggers.
class LoggerRegistry
{
public:
	static LoggerRegistry& singleton();

	/// @returns the logger for @a _category, creating and registering it first if it doesn't exist yet.
	Logger const& get(std::string_view _category);

	/// Adds the rule (@a _prefix, @a _level), replacing any existing rule for the same prefix, then sets
	/// every logger to the level of its longest matching rule prefix, or 0 if none matches.
	void setLevel(std::string_view _prefix, Level _level);

	/// @returns true if @a _prefix matches at least one registered category.
	bool matchesAnyCategory(std::string_view _prefix) const;

	/// @returns sorted registered categories
	std::vector<std::string> categories() const;

	/// Directs log output to @a _stream, which must outlive its use by the registry.
	void setOutput(std::ostream& _stream);

	void reset();

private:
	LoggerRegistry();
	~LoggerRegistry();

	Level computeEffectiveLevel(std::string_view _category) const;

	/// Writes a line prefixed with "[<seconds since startup>s L<level> <category>]"
	void write(Level _level, std::string_view _category, std::string const& _message);

	friend class Logger;

	std::chrono::steady_clock::time_point const m_startTime;
	std::map<std::string, Level, std::less<>> m_rules;
	std::unordered_map<std::string, std::unique_ptr<LoggerHandle>> m_loggers;
	std::ostream* m_output;
};

}

/// Defines a logger reference bound once to @a dottedCategory, which must be a string literal matching
/// `[a-z0-9_-]+(\.[a-z0-9_-]+)*`.
/// Must be used at namespace scope, so that the category is registered during static initialisation, before the CLI is parsed.
#define DEFINE_LOGGER(variableName, dottedCategory) \
	static_assert( \
		::solidity::log::isValidCategory(dottedCategory), \
		"Invalid logger category \"" dottedCategory "\": must match [a-z0-9_-]+(\\.[a-z0-9_-]+)*" \
	); \
	static ::solidity::log::Logger const& variableName = \
		::solidity::log::LoggerRegistry::singleton().get(dottedCategory)

/// Arguments are only evaluated if the logger is enabled at @a level.
#define solLog(logger, level, ...) \
	do \
	{ \
		static_assert( \
			1 <= (level) && (level) <= ::solidity::log::maxLevel, \
			"Log level must be a constant between 1 and solidity::log::maxLevel" \
		); \
		::solidity::log::Logger const& solLogger_ = (logger); \
		if (solLogger_.shouldLog(level)) [[unlikely]] \
			solLogger_.log((level), __VA_ARGS__); \
	} while (0)

#define solLog1(logger, ...) solLog((logger), 1, __VA_ARGS__)
#define solLog2(logger, ...) solLog((logger), 2, __VA_ARGS__)
#define solLog3(logger, ...) solLog((logger), 3, __VA_ARGS__)
