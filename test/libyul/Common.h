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
/**
 * @date 2017
 * Common functions the Yul tests.
 */

#pragma once

#include <libsolidity/interface/OptimiserSettings.h>

#include <liblangutil/EVMVersion.h>

#include <string>
#include <vector>
#include <memory>
#include <optional>

namespace solidity::langutil
{
class Error;
using ErrorList = std::vector<std::shared_ptr<Error const>>;
}

namespace solidity::yul
{
struct AsmAnalysisInfo;
struct Block;
class Object;
class Dialect;
class AST;
class YulStack;
}

namespace solidity::yul::test
{

yul::YulStack parseYul(
	std::string const& _source,
	std::string _sourceUnitName = "",
	std::optional<frontend::OptimiserSettings> _optimiserSettings = std::nullopt
);

Block disambiguate(std::string const& _source);
std::string format(std::string const& _source);

solidity::yul::Dialect const& dialect(std::string const& _name, langutil::EVMVersion _evmVersion, std::optional<uint8_t> _eofVersion);

void printYulErrors(
	yul::YulStack const& _yulStack,
	std::ostream& _stream,
	std::string const& _linePrefix,
	bool const _formatted
);

}
