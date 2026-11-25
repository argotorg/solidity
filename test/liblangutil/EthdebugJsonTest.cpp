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

#include <test/liblangutil/EthdebugJsonTest.h>

#include <liblangutil/EthdebugJson.h>
#include <liblangutil/EthdebugSchema.h>
#include <liblangutil/SemanticDebugDataSerialization.h>

#include <libsolutil/CommonData.h>
#include <libsolutil/JSON.h>

#include <boost/throw_exception.hpp>

#include <stdexcept>
#include <string>

using namespace solidity;
using namespace solidity::frontend::test;
using namespace solidity::langutil;
using namespace solidity::langutil::ethdebug;
using namespace solidity::langutil::test;
using namespace solidity::util;

namespace
{

Json roundTripResources(Json const& _input)
{
	requireOnlyMembers(_input, {"types", "pointers"}, "resources");
	Json output = Json::object();
	if (Json const* types = checkAndFindMember(_input, "types", "resources"))
		output["types"] = schema::info::typesFromJSON(*types, "resources.types");
	if (Json const* pointers = checkAndFindMember(_input, "pointers", "resources"))
		output["pointers"] = schema::info::pointersFromJSON(*pointers, "resources.pointers");
	return output;
}

Json roundTripSidecar(Json const& _input)
{
	return semanticDebugDataToJSON(semanticDebugDataFromJSON(_input));
}

}

std::unique_ptr<TestCase> EthdebugJsonTest::createResourcesTest(Config const& _config)
{
	return std::make_unique<EthdebugJsonTest>(_config.filename, roundTripResources);
}

std::unique_ptr<TestCase> EthdebugJsonTest::createSidecarTest(Config const& _config)
{
	return std::make_unique<EthdebugJsonTest>(_config.filename, roundTripSidecar);
}

EthdebugJsonTest::EthdebugJsonTest(std::string const& _filename, RoundTrip _roundTrip):
	TestCase(_filename),
	m_roundTrip(_roundTrip)
{
	m_source = m_reader.source();
	m_expectation = m_reader.simpleExpectations();
	if (!_filename.ends_with(".ethdebugjson"))
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"Not an ETHDebug JSON test: \"" + _filename + "\". Expected extension: .ethdebugjson."
		));
}

TestCase::TestResult EthdebugJsonTest::run(std::ostream& _stream, std::string const& _linePrefix, bool const _formatted)
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
		Json const output = m_roundTrip(input);
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
