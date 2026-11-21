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

#include <libsolutil/JSON.h>

#include <boost/throw_exception.hpp>

#include <stdexcept>
#include <string>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::langutil::test;

EthdebugDocumentTest::EthdebugDocumentTest(std::string const& _filename):
	TestCase(_filename)
{
	m_source = m_reader.source();
	m_expectation = m_reader.simpleExpectations();
	m_document = m_reader.enumSetting<Document>("document", {
		{"json", Document::JSON},
	}, "json");
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

	Json output;
	switch (m_document)
	{
	case Document::JSON:
		output = input;
		break;
	}
	m_obtainedResult = jsonPrint(output, JsonFormat{JsonFormat::Pretty, 4}) + "\n";

	return checkResult(_stream, _linePrefix, _formatted);
}
