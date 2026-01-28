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

#include <test/libyul/Common.h>

#include <test/libsolidity/util/SoltestErrors.h>

#include <test/Common.h>

#include <libyul/optimiser/Disambiguator.h>
#include <libyul/AsmAnalysis.h>
#include <libyul/AsmPrinter.h>
#include <libyul/YulStack.h>
#include <libyul/AST.h>
#include <libyul/backends/evm/EVMDialect.h>

#include <libsolutil/AnsiColorized.h>

#include <liblangutil/DebugInfoSelection.h>
#include <liblangutil/ErrorReporter.h>
#include <liblangutil/Scanner.h>
#include <liblangutil/SourceReferenceFormatter.h>

#include <boost/test/unit_test.hpp>

#include <variant>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::yul;
using namespace solidity::langutil;
using namespace solidity::util;
using namespace solidity::test;

YulStack yul::test::parseYul(
	std::string const& _source,
	std::string _sourceUnitName,
	std::optional<frontend::OptimiserSettings> _optimiserSettings
)
{
	YulStack yulStack(
		CommonOptions::get().evmVersion(),
		CommonOptions::get().eofVersion(),
		YulStack::Language::StrictAssembly,
		_optimiserSettings.has_value() ?
			*_optimiserSettings :
			(CommonOptions::get().optimize ? OptimiserSettings::standard() : OptimiserSettings::minimal()),
		DebugInfoSelection::AllExceptExperimental()
	);
	bool successful = yulStack.parseAndAnalyze(_sourceUnitName, _source);
	if (!successful)
		soltestAssert(yulStack.hasErrors());
	else
	{
		soltestAssert(!yulStack.hasErrors());
		soltestAssert(yulStack.parserResult());
		soltestAssert(yulStack.parserResult()->code());
		soltestAssert(yulStack.parserResult()->analysisInfo);
	}
	return yulStack;
}

yul::Block yul::test::disambiguate(std::string const& _source)
{
	YulStack yulStack = parseYul(_source);
	soltestAssert(!yulStack.hasErrorsWarningsOrInfos());
	return std::get<Block>(Disambiguator(
		yulStack.dialect(),
		*yulStack.parserResult()->analysisInfo,
		{}
	)(yulStack.parserResult()->code()->root()));
}

std::string yul::test::format(std::string const& _source)
{
	YulStack yulStack = parseYul(_source);
	solUnimplementedAssert(yulStack.parserResult()->subObjects.empty(), "Subobjects not supported.");
	soltestAssert(!yulStack.hasErrorsWarningsOrInfos());
	return AsmPrinter::format(*yulStack.parserResult()->code());
}

namespace
{
std::map<std::string const, yul::Dialect const& (*)(langutil::EVMVersion, std::optional<uint8_t>)> const validDialects = {
	{
		"evm",
		[](langutil::EVMVersion _evmVersion, std::optional<uint8_t> _eofVersion) -> yul::Dialect const&
		{ return yul::EVMDialect::strictAssemblyForEVMObjects(_evmVersion, _eofVersion); }
	}
};

	std::vector<std::string> validDialectNames()
{
	std::vector<std::string> names{size(validDialects), ""};
	std::transform(begin(validDialects), end(validDialects), names.begin(), [](auto const& dialect) { return dialect.first; });

	return names;
}
}

yul::Dialect const& yul::test::dialect(std::string const& _name, langutil::EVMVersion _evmVersion, std::optional<uint8_t> _eofVersion)
{
	if (!validDialects.count(_name))
		BOOST_THROW_EXCEPTION(std::runtime_error{
			"Invalid Dialect \"" +
			_name +
			"\". Valid dialects are " +
			util::joinHumanReadable(validDialectNames(), ", ", " and ") +
			"."
		});

	return validDialects.at(_name)(_evmVersion, _eofVersion);
}

void yul::test::printYulErrors(
	YulStack const& _yulStack,
	std::ostream& _stream,
	std::string const& _linePrefix,
	bool const _formatted
)
{
	AnsiColorized(_stream, _formatted, {formatting::BOLD, formatting::RED})
		<< _linePrefix
		<< "Error parsing source."
		<< std::endl;
	SourceReferenceFormatter formatter{_stream, _yulStack, true, false};
	formatter.printErrorInformation(_yulStack.errors());
}
