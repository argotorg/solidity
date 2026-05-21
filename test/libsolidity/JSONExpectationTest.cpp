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

#include <test/libsolidity/JSONExpectationTest.h>
#include <test/libsolidity/util/Common.h>

#include <libsolutil/CommonIO.h>
#include <libsolutil/JSON.h>
#include <libsolutil/StringUtils.h>

#include <boost/throw_exception.hpp>

#include <algorithm>
#include <stdexcept>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::frontend::test;
using namespace solidity::util;
using namespace std::string_literals;

JSONExpectationTest::JSONExpectationTest(std::string const& _filename):
	EVMVersionRestrictedTestCase(_filename),
	m_sources(m_reader.sources())
{
	parseExpectations(m_reader.stream());
}

void JSONExpectationTest::parseExpectations(std::istream& _stream)
{
	std::string line;
	while (getline(_stream, line))
	{
		if (!line.starts_with("// "))
		{
			if (line == "//")
				continue;
			BOOST_THROW_EXCEPTION(std::runtime_error("Invalid expectation: expected \"// \" prefix in line: " + line));
		}

		std::string_view stripped(line);
		stripped.remove_prefix(3);

		auto const startPos = stripped.find_first_not_of(" \t");
		if (startPos == std::string_view::npos)
			continue;
		stripped.remove_prefix(startPos);

		auto const colonPos = stripped.rfind(':');
		if (colonPos != std::string_view::npos &&
			stripped.find_first_not_of(" \t", colonPos + 1) == std::string_view::npos)
		{
			Expectation exp = parsePathPart(stripped.substr(0, colonPos));
			exp.value = extractMultiLineExpectationJSON(_stream);
			m_expectations.push_back(std::move(exp));
		}
		else
			m_expectations.push_back(parseSingleLineExpectation(stripped, _stream));
	}
}

// TODO: O(N^2) — Json::accept() reparses the whole block per line. Acceptable at current
//       fixture sizes; switch to indent-based termination if it becomes a problem.
Json JSONExpectationTest::extractMultiLineExpectationJSON(std::istream& _stream, std::string _rawJSON)
{
	if (!_rawJSON.empty())
		_rawJSON += "\n";

	auto const finalize = [&]() {
		Json parsed;
		std::string errors;
		if (!jsonParseStrict(_rawJSON, parsed, &errors))
			BOOST_THROW_EXCEPTION(std::runtime_error(
				"Failed to parse JSON expectation block:\n" + _rawJSON + "\nErrors:\n" + errors
			));
		return parsed;
	};

	if (Json::accept(_rawJSON))
		return finalize();

	std::string line;
	while (getline(_stream, line))
	{
		std::string_view stripped;
		if (line.starts_with("// "))
			stripped = std::string_view(line).substr(3);
		else if (line == "//")
			stripped = "";
		else
			BOOST_THROW_EXCEPTION(std::runtime_error("Invalid expectation: expected \"// \" prefix in JSON block: " + line));

		_rawJSON += stripped;
		_rawJSON += "\n";

		if (Json::accept(_rawJSON))
			return finalize();
	}
	std::string errors;
	Json discarded;
	jsonParseStrict(_rawJSON, discarded, &errors);
	BOOST_THROW_EXCEPTION(std::runtime_error(
		"Unterminated or malformed multi-line JSON expectation block:\n" + _rawJSON +
		(errors.empty() ? "" : "\nErrors:\n" + errors)
	));
}

JSONExpectationTest::Expectation JSONExpectationTest::parseSingleLineExpectation(std::string_view _line, std::istream& _stream)
{
	auto const colonPos = _line.find(": ");
	if (colonPos == std::string_view::npos)
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"Missing ': ' separator in expectation line: "s.append(_line)
		));

	std::string_view const pathPart = _line.substr(0, colonPos);
	std::string const rawValue(_line.substr(colonPos + 2));

	Expectation result = parsePathPart(pathPart);
	Json parsed;
	if (jsonParseStrict(rawValue, parsed))
		result.value = std::move(parsed);
	else if (!rawValue.empty() && (rawValue.front() == '{' || rawValue.front() == '['))
		result.value = extractMultiLineExpectationJSON(_stream, rawValue);
	else
		result.value = Json(rawValue);
	return result;
}

JSONExpectationTest::Expectation JSONExpectationTest::parsePathPart(std::string_view _pathPart)
{
	Expectation result;

	auto const pipePos = _pathPart.find(" | ");
	if (pipePos != std::string_view::npos)
	{
		result.filter = std::string(_pathPart.substr(pipePos + 3));
		_pathPart = _pathPart.substr(0, pipePos);
	}

	result.fullPath = std::string(_pathPart);
	return result;
}

JSONExpectationTest::PathParts JSONExpectationTest::splitPath(std::string_view _path) const
{
	auto const open = _path.find('(');
	if (open == std::string_view::npos)
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"Path must use `(scope) jsonPath` form: "s.append(_path)
		));
	auto const close = _path.find(')', open);
	if (close == std::string_view::npos)
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"Unterminated `(...)` scope in path: "s.append(_path)
		));

	auto const trimLeading = [](std::string_view _sv) {
		_sv.remove_prefix(std::min(_sv.find_first_not_of(" \t"), _sv.size()));
		return _sv;
	};

	std::string_view const inside = trimLeading(_path.substr(open + 1, close - open - 1));
	std::string_view const jsonPath = trimLeading(_path.substr(close + 1));

	auto const sep = inside.find_first_of(" \t");
	if (sep == std::string_view::npos)
		return {std::string_view{}, inside, jsonPath};
	return {inside.substr(0, sep), trimLeading(inside.substr(sep)), jsonPath};
}

namespace
{
// Convert expectation path, e.g. "instructions[0].offset" to RFC 6901 JSON pointer, i.e.
// /instructions/0/offset to be later used in JSON lookups.
nlohmann::json::json_pointer pathToPointer(std::string_view _path)
{
	if (_path.empty())
		return nlohmann::json::json_pointer{};

	std::string ptr = "/";
	for (char c: _path)
	{
		if (c == '.' || c == '[')
			ptr += '/';
		else if (c != ']')
			ptr += c;
	}
	return nlohmann::json::json_pointer(ptr);
}
}

std::optional<Json> JSONExpectationTest::resolvePath(Json const& _json, std::string_view _path) const
{
	auto const ptr = pathToPointer(_path);
	if (!_json.contains(ptr))
		return std::nullopt;
	return _json.at(ptr);
}

Json JSONExpectationTest::applyFilter(Json const& _json, std::string_view _filter) const
{
	if (_filter == "length")
	{
		if (_json.is_array() || _json.is_object())
			return Json(static_cast<uint64_t>(_json.size()));
		if (_json.is_string())
			return Json(static_cast<uint64_t>(_json.get<std::string>().size()));
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"'length' filter requires an array, object, or string; got "s + _json.type_name()
		));
	}
	if (_filter == "type")
		return Json(_json.type_name());
	if (_filter == "keys")
	{
		if (!_json.is_object())
			BOOST_THROW_EXCEPTION(std::runtime_error(
				"'keys' filter requires an object; got "s + _json.type_name()
			));
		Json result = Json::array();
		// Json uses std::map for object storage, so items() iterates keys in
		// lexicographic order. Tests rely on this for stable output.
		for (auto const& [key, _]: _json.items())
			result.push_back(key);
		return result;
	}

	BOOST_THROW_EXCEPTION(std::runtime_error("Unknown filter: "s.append(_filter)));
}

std::string JSONExpectationTest::formatPathPrefix(Expectation const& _exp)
{
	return _exp.filter.empty() ? _exp.fullPath : _exp.fullPath + " | " + _exp.filter;
}

std::string JSONExpectationTest::formatValueAs(Json const& _value) const
{
	if (_value.is_string())
	{
		auto const& content = _value.get_ref<std::string const&>();
		Json probe;
		if (jsonParseStrict(content, probe))
			return _value.dump();
		return content;
	}
	if (_value.is_object() || _value.is_array())
	{
		bool const hasNested = std::any_of(_value.begin(), _value.end(), [](Json const& _el) {
			return _el.is_structured();
		});
		return hasNested
			? jsonPrint(_value, {JsonFormat::Pretty, 4})
			: jsonCompactPrint(_value);
	}
	return _value.dump();
}

void JSONExpectationTest::applyPlaceholders(Json const& _expected, Json& _obtained) const
{
	if (_expected.is_string() && _expected.get<std::string>() == "<IGNORE>")
	{
		_obtained = _expected;
		return;
	}
	if (_expected.type() != _obtained.type())
		return;
	if (_expected.is_object())
	{
		for (auto const& [key, expectedVal]: _expected.items())
			if (_obtained.contains(key))
				applyPlaceholders(expectedVal, _obtained[key]);
	}
	else if (_expected.is_array())
		for (size_t i = 0; i < std::min(_expected.size(), _obtained.size()); ++i)
			applyPlaceholders(_expected[i], _obtained[i]);
}

TestCase::TestResult JSONExpectationTest::run(std::ostream& _stream, std::string const& _linePrefix, bool _formatted)
{
	if (!runFramework(withPreamble(m_sources.sources), PipelineStage::Compilation))
	{
		printPrefixed(_stream, formatErrors(filteredErrors(false /* _includeWarningsAndInfos */), _formatted), _linePrefix);
		return TestResult::FatalError;
	}

	bool const allMatch = std::ranges::all_of(m_expectations, [&](Expectation const& _expectation) {
		auto const parts = splitPath(_expectation.fullPath);
		auto const isExpected = [&](std::string_view _sentinel) {
			return _expectation.value.is_string() && _expectation.value.get<std::string>() == _sentinel;
		};

		auto const output = fetchOutput(parts.qualifiedContract, parts.outputName);
		if (!output)
			return isExpected("<SCOPE NOT FOUND>");

		auto const actualLookup = resolvePath(*output, parts.jsonPath);
		if (!actualLookup)
			return isExpected("<PATH NOT FOUND>");

		Json actualJson = *actualLookup;
		if (!_expectation.filter.empty())
			actualJson = applyFilter(actualJson, _expectation.filter);

		Json patched = actualJson;
		applyPlaceholders(_expectation.value, patched);
		return patched == _expectation.value;
	});

	if (allMatch)
		return TestResult::Success;

	_stream << _linePrefix << "Expected:" << std::endl;
	printPrefixed(_stream, formatExpectations(m_expectations), _linePrefix + "  ");
	_stream << _linePrefix << "Obtained:" << std::endl;
	printUpdatedExpectations(_stream, _linePrefix + "  ");
	return TestResult::Failure;
}

void JSONExpectationTest::printSource(std::ostream& _stream, std::string const& _linePrefix, bool /*_formatted*/) const
{
	if (m_sources.sources.empty())
		return;

	bool const outputSourceNames = m_sources.sources.size() != 1 || !m_sources.sources.begin()->first.empty();
	for (auto const& [name, source]: m_sources.sources)
	{
		if (outputSourceNames)
			_stream << _linePrefix << "==== Source: " << name << " ====" << std::endl;
		printPrefixed(_stream, source, _linePrefix);
	}
}

std::string JSONExpectationTest::formatExpectations(std::vector<Expectation> const& _expectations) const
{
	std::string output;
	for (auto const& exp: _expectations)
	{
		std::string const formatted = formatValueAs(exp.value);
		output += formatPathPrefix(exp) + ": " + formatted;
		if (formatted.empty() || formatted.back() != '\n')
			output += '\n';
	}
	return output;
}

void JSONExpectationTest::printUpdatedExpectations(std::ostream& _stream, std::string const& _linePrefix) const
{
	for (auto const& exp: m_expectations)
	{
		auto const parts = splitPath(exp.fullPath);
		std::string const pathPrefix = formatPathPrefix(exp);

		auto const output = fetchOutput(parts.qualifiedContract, parts.outputName);
		if (!output)
		{
			_stream << _linePrefix << pathPrefix << ": <SCOPE NOT FOUND>" << std::endl;
			continue;
		}

		auto const resolved = resolvePath(*output, parts.jsonPath);
		if (!resolved)
		{
			_stream << _linePrefix << pathPrefix << ": <PATH NOT FOUND>" << std::endl;
			continue;
		}

		Json value = *resolved;
		if (!exp.filter.empty())
			value = applyFilter(value, exp.filter);
		applyPlaceholders(exp.value, value);

		std::string const formatted = formatValueAs(value);
		printPrefixed(_stream, pathPrefix + ": " + formatted, _linePrefix);
	}
}
