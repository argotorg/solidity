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

#include <test/TestCase.h>

#include <libsolutil/JSON.h>

#include <memory>
#include <ostream>
#include <string>

namespace solidity::langutil::test
{

/// Reads and serializes an ETHDebug fixture and reports changes.
class EthdebugJsonTest: public frontend::test::TestCase
{
public:
	using RoundTrip = Json (*)(Json const&);

	static std::unique_ptr<TestCase> createResourcesTest(Config const& _config);
	static std::unique_ptr<TestCase> createSidecarTest(Config const& _config);
	EthdebugJsonTest(std::string const& _filename, RoundTrip _roundTrip);

	TestResult run(std::ostream& _stream, std::string const& _linePrefix = "", bool const _formatted = false) override;

private:
	RoundTrip m_roundTrip;
};

}
