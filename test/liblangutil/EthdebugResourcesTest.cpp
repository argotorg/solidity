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

#include <libsolutil/JSON.h>

#include <boost/throw_exception.hpp>

#include <stdexcept>
#include <string>

using namespace solidity;
using namespace solidity::frontend::test;
using namespace solidity::util;
using namespace solidity::langutil::test;

namespace
{
std::string const& validateResourcesTestFilename(std::string const& _filename)
{
	if (!_filename.ends_with(".ethdebugjson"))
		BOOST_THROW_EXCEPTION(std::runtime_error(
			"Not an ETHDebug resources test: \"" + _filename + "\". Expected extension: .ethdebugjson."
		));
	return _filename;
}
}

EthdebugResourcesTest::EthdebugResourcesTest(std::string const& _filename):
	TestCase(validateResourcesTestFilename(_filename))
{
	m_source = m_reader.source();
	m_expectation = m_reader.simpleExpectations();
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

	std::string const serializedInput = jsonPrint(input, JsonFormat{JsonFormat::Pretty, 4});
	m_obtainedResult = Json::parse(serializedInput) == input ? "Input and output are identical.\n" : serializedInput + '\n';

	return checkResult(_stream, _linePrefix, _formatted);
}
