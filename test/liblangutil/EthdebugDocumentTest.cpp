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

#include <test/liblangutil/EthdebugDocumentTest.h>

#include <liblangutil/EthdebugSchema.h>

#include <libsolutil/JSON.h>

#include <boost/throw_exception.hpp>

#include <stdexcept>
#include <string>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::langutil::test;

namespace schema = solidity::langutil::ethdebug::schema;

EthdebugDocumentTest::EthdebugDocumentTest(std::string const& _filename):
	TestCase(_filename)
{
	m_source = m_reader.source();
	m_expectation = m_reader.simpleExpectations();
	m_document = m_reader.enumSetting<Document>("document", {
		{"json", Document::JSON},
		{"types", Document::Types},
		{"resources", Document::Resources},
	}, "resources");
	if (!_filename.ends_with(".ethdebugjson"))
		BOOST_THROW_EXCEPTION(std::runtime_error("Not an ethdebug document test: \"" + _filename + "\". Expected extension: .ethdebugjson."));
}

frontend::test::TestCase::TestResult EthdebugDocumentTest::run(std::ostream& _stream, std::string const& _linePrefix, bool const _formatted)
{
	Json input;
	std::string parseError;
	if (!jsonParseStrict(m_source, input, &parseError))
	{
		m_obtainedResult = "Error: " + parseError + "\n";
		return checkResult(_stream, _linePrefix, _formatted);
	}

	try
	{
		Json output;
		switch (m_document)
		{
		case Document::JSON:
			output = input;
			break;
		case Document::Types:
			output = schema::info::typesFromJson(input, "types");
			break;
		case Document::Resources:
			requireOnlyMembers(input, {"types", "pointers"}, "resources");
			output = Json{{"types", Json::object()}, {"pointers", Json::object()}};
			if (input.contains("types"))
				output["types"] = schema::info::typesFromJson(input.at("types"), "resources.types");
			if (input.contains("pointers"))
				output["pointers"] = schema::info::pointersFromJson(input.at("pointers"), "resources.pointers");
			break;
		}
		m_obtainedResult = jsonPrint(output, JsonFormat{JsonFormat::Pretty, 4}) + "\n";
	}
	catch (JsonValidationError const& _error)
	{
		m_obtainedResult = "Error: " + stringOrDefault(_error.comment()) + "\n";
	}

	return checkResult(_stream, _linePrefix, _formatted);
}
