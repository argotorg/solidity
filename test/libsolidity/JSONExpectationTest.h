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

#pragma once

#include <test/libsolidity/AnalysisFramework.h>
#include <test/TestCase.h>
#include <test/TestCaseReader.h>
#include <libsolutil/JSON.h>

#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace solidity::frontend::test
{
/// Base class for isoltest test cases that drive a Solidity compilation and assert
/// against a JSON output.
///
/// Expectations
/// ------------
///     // path [| filter]: expected
///
/// `expected` is a JSON value and may continue across subsequent `// ` lines. Bare
/// scalars like `solc`, `PUSH1`, `0x80` or `<IGNORE>` are accepted without quoting;
/// use the quoted form (e.g. `"42"`) for strings whose content looks like another
/// JSON type. Lines without `: ` are rejected.
///
/// Filters (applied to the resolved value before comparison):
///   - `| length` — array/object/string size as a number
///   - `| type`   — JSON type name ("object", "array", "number", …)
///   - `| keys`   — list of keys (object only); always lexicographically sorted
///
/// Sentinels (assert absence):
///   - `<SCOPE NOT FOUND>` — passes when the referenced contract/output is absent
///   - `<PATH NOT FOUND>`  — passes when the inner JSON path is absent
///
/// Placeholder:
///   - `<IGNORE>` matches any value at the position where it appears.
///     Limitations: only works at string leaves (not as a dict key); matches whole
///     values (not fragments like `v<IGNORE>`); has no escape; multiple occurrences
///     match independently.
///
/// Example:
///     // C.instructions[0].offset: 0
///     // C.instructions | length: 3
///     // C.compilation: {
///     //     "compiler": {"name": "solc", "version": "<IGNORE>"}
///     // }
///     // Missing.contract.name: <SCOPE NOT FOUND>
///     // C.contract.nope:       <PATH NOT FOUND>
class JSONExpectationTest: public AnalysisFramework, public EVMVersionRestrictedTestCase
{
public:
	JSONExpectationTest(std::string const& _filename);

	TestResult run(std::ostream& _stream, std::string const& _linePrefix = "", bool _formatted = false) override;
	void printSource(std::ostream& _stream, std::string const& _linePrefix = "", bool _formatted = false) const override;
	void printUpdatedExpectations(std::ostream& _stream, std::string const& _linePrefix) const override;

protected:
	struct Expectation
	{
		std::string fullPath;
		std::string filter;       // optional filter, e.g. "length"
		Json value;               // parsed expected value (placeholder leaves stored as their literal name)
	};

	struct PathParts
	{
		std::string_view qualifiedContract;
		std::string_view outputName;
		std::string_view jsonPath;
	};

	/// Splits a path into (qualifiedContract, outputName, jsonPath). Default parses `(scope) jsonPath`.
	virtual PathParts splitPath(std::string_view _path) const;

	virtual std::optional<Json> fetchOutput(
		std::string_view _qualifiedContract,
		std::string_view _outputName
	) const = 0;

private:
	void parseExpectations(std::istream& _stream);
	Expectation parseSingleLineExpectation(std::string_view _line, std::istream& _stream);
	Expectation parsePathPart(std::string_view _pathPart);
	Json extractMultiLineExpectationJSON(std::istream& _stream, std::string _rawJSON = "");

	std::optional<Json> resolvePath(Json const& _json, std::string_view _path) const;
	Json applyFilter(Json const& _json, std::string_view _filter) const;
	std::string formatValueAs(Json const& _value) const;
	void applyPlaceholders(Json const& _expected, Json& _obtained) const;
	std::string formatExpectations(std::vector<Expectation> const& _expectations) const;
	static std::string formatPathPrefix(Expectation const& _exp);

	SourceMap m_sources;
	std::vector<Expectation> m_expectations;
};

} // namespace
