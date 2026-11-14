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
/// Test case that reads an ethdebug JSON document, validates it and writes it back.

#pragma once

#include <test/TestCase.h>

#include <memory>
#include <ostream>
#include <string>

namespace solidity::langutil::test
{

/// Parses a JSON document and compares its serialized form or parse error
/// with the expectation. Document kinds select the reader to test.
///
/// Available settings:
/// - document: The document kind.
///     - `json` parses and formats JSON.
///     - `types` reads an ethdebug type table.
///     - `resources` (the default) reads the type and pointer tables of
///       ethdebug/format/info/resources.
class EthdebugDocumentTest: public frontend::test::TestCase
{
public:
	static std::unique_ptr<TestCase> create(Config const& _config)
	{
		return std::make_unique<EthdebugDocumentTest>(_config.filename);
	}
	EthdebugDocumentTest(std::string const& _filename);

	TestResult run(std::ostream& _stream, std::string const& _linePrefix = "", bool const _formatted = false) override;

private:
	enum class Document
	{
		JSON,
		Types,
		Resources,
	};

	Document m_document = Document::Resources;
};

}
