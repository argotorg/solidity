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

#include <libsolutil/Logger.h>

#include <algorithm>
#include <iostream>

using namespace solidity::log;

namespace solidity::log
{

/// Logger owned by the registry, together with the category name and effective level it refers to.
struct LoggerHandle
{
	LoggerHandle(std::string _category, Level _level):
		category(std::move(_category)),
		effectiveLevel(_level),
		logger(&effectiveLevel, category)
	{}

	std::string category;
	Level effectiveLevel;
	Logger logger;
};

}

bool solidity::log::prefixMatches(std::string_view _prefix, std::string_view _category) noexcept
{
	if (_prefix.empty())
		return true;
	return
		_category.starts_with(_prefix) &&
		(_category.size() == _prefix.size() || _category[_prefix.size()] == '.');
}

LoggerRegistry& LoggerRegistry::singleton()
{
	static LoggerRegistry registry;
	return registry;
}

LoggerRegistry::LoggerRegistry():
	m_startTime(std::chrono::steady_clock::now()),
	m_output(&std::cerr)
{
}

LoggerRegistry::~LoggerRegistry() = default;

Logger const& LoggerRegistry::get(std::string_view _category)
{
	std::string category{_category};
	if (
		auto const loggerHandle = m_loggers.find(category);
		loggerHandle != m_loggers.end()
	)
		return loggerHandle->second->logger;

	Level const effectiveLevel = computeEffectiveLevel(category);
	auto [newLoggerHandle, _] = m_loggers.emplace(category, std::make_unique<LoggerHandle>(category, effectiveLevel));
	return newLoggerHandle->second->logger;
}

void LoggerRegistry::setLevel(std::string_view _prefix, Level _level)
{
	m_rules.insert_or_assign(std::string(_prefix), _level);

	for (auto& [category, loggerHandle]: m_loggers)
		loggerHandle->effectiveLevel = computeEffectiveLevel(category);
}

bool LoggerRegistry::matchesAnyCategory(std::string_view _prefix) const
{
	return std::any_of(m_loggers.begin(), m_loggers.end(), [&](auto const& _logger) {
		return prefixMatches(_prefix, _logger.first);
	});
}

std::vector<std::string> LoggerRegistry::categories() const
{
	std::vector<std::string> result;
	result.reserve(m_loggers.size());
	for (auto const& [category, _]: m_loggers)
		result.push_back(category);
	std::sort(result.begin(), result.end());
	return result;
}

void LoggerRegistry::setOutput(std::ostream& _stream)
{
	m_output = &_stream;
}

void LoggerRegistry::reset()
{
	m_rules.clear();
	for (auto& [category, loggerHandle]: m_loggers)
		loggerHandle->effectiveLevel = 0;
	setOutput(std::cerr);
}

Level LoggerRegistry::computeEffectiveLevel(std::string_view _category) const
{
	// Look up the category itself, then each shorter whole-component prefix, then the empty prefix.
	std::string_view prefix = _category;
	while (true)
	{
		if (
			auto const rule = m_rules.find(prefix);
			rule != m_rules.end()
		)
			return rule->second;
		if (prefix.empty())
			return 0;
		auto const dot = prefix.rfind('.');
		prefix = prefix.substr(0, dot == std::string_view::npos ? 0 : dot);
	}
}

void LoggerRegistry::write(Level _level, std::string_view _category, std::string const& _message)
{
	std::chrono::duration<double> const elapsed = std::chrono::steady_clock::now() - m_startTime;
	(*m_output) << fmt::format("[{:8.3f}s L{} {}] {}\n", elapsed.count(), unsigned{_level}, _category, _message);
}

void Logger::emitFormatted(Level _level, std::string const& _message) const
{
	LoggerRegistry::singleton().write(_level, m_category, _message);
}
