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

#include <test/liblangutil/EthdebugResourcesTest.h>

#include <liblangutil/EthdebugJson.h>
#include <liblangutil/EthdebugSchema.h>

#include <libsolutil/CommonData.h>
#include <libsolutil/JSON.h>

#include <boost/throw_exception.hpp>

#include <stdexcept>
#include <string>

using namespace solidity;
using namespace solidity::frontend::test;
using namespace solidity::langutil::ethdebug;
using namespace solidity::langutil::test;
using namespace solidity::util;

EthdebugResourcesTest::EthdebugResourcesTest(std::string const& _filename):
	TestCase(_filename)
{
	m_source = m_reader.source();
	m_expectation = m_reader.simpleExpectations();
	if (!_filename.ends_with(".ethdebugjson"))
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"Not an ETHDebug resources test: \"" + _filename + "\". Expected extension: .ethdebugjson."
		));
}

TestCase::TestResult EthdebugResourcesTest::run(std::ostream& _stream, std::string const& _linePrefix, bool const _formatted)
{
	Json input;
	std::string parseError;
	if (!jsonParseStrict(m_source, input, &parseError))
	{
		_stream << _linePrefix << "Malformed JSON in test input: " << parseError << '\n';
		return TestResult::FatalError;
	}

	try
	{
		requireOnlyMembers(input, {"types", "pointers"}, "resources");
		Json output = Json::object();
		if (Json const* types = checkAndFindMember(input, "types", "resources"))
			output["types"] = schema::info::typesFromJSON(*types, "resources.types");
		if (Json const* pointers = checkAndFindMember(input, "pointers", "resources"))
			output["pointers"] = schema::info::pointersFromJSON(*pointers, "resources.pointers");
		Json const changes = Json::diff(input, output);
		m_obtainedResult = changes.empty() ?
			"Input and output are identical.\n" :
			jsonPrint(changes, JsonFormat{JsonFormat::Pretty, 4}) + '\n';
	}
	catch (JsonValidationError const& _error)
	{
		m_obtainedResult = "Error: " + stringOrDefault(_error.comment()) + '\n';
	}

	return checkResult(_stream, _linePrefix, _formatted);
}
