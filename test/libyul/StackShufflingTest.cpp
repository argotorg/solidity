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

#include <test/libyul/StackShufflingTest.h>

#include <test/Common.h>

#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/backends/evm/StackHelpers.h>

#include <liblangutil/Scanner.h>
#include <libsolutil/AnsiColorized.h>
#include <libsolutil/StringUtils.h>

using namespace solidity::test;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::yul;
using namespace solidity::yul::test;

bool StackShufflingTest::parse(std::string const& _source)
{
	CharStream stream(_source, "");
	Scanner scanner(stream);

	auto expectToken = [&](Token _token)
	{
		soltestAssert(
			scanner.next() == _token,
			"Invalid token. Expected: \"" + TokenTraits::friendlyName(_token) + "\"."
        );
	};

	auto parseStack = [&](Stack& stack) -> bool
	{
		if (scanner.currentToken() != Token::LBrack)
			return false;
		scanner.next();
		while (scanner.currentToken() != Token::RBrack &&
			   scanner.currentToken() != Token::EOS)
		{
			std::string literal = scanner.currentLiteral();
			if (literal == "RET")
			{
				scanner.next();
				if (scanner.currentToken() == Token::LBrack)
				{
					scanner.next();
					std::string functionLabel = scanner.currentLiteral();
					auto const functionLabelID = m_labelRegistryBuilder.define(functionLabel);
					auto call = yul::FunctionCall{
						{}, yul::Identifier{{}, functionLabelID}, {}
					};
					stack.emplace_back(FunctionCallReturnLabelSlot{
						m_functions.emplace(functionLabelID, call).first->second
					});
					expectToken(Token::RBrack);
				}
				else
				{
					static Scope::Function function;
					stack.emplace_back(FunctionReturnLabelSlot{function});
					continue;
				}
			}
			else if (literal == "TMP")
			{
				expectToken(Token::LBrack);
				scanner.next();
				std::string functionName = scanner.currentLiteral();
				auto const functionLabelID = m_labelRegistryBuilder.define(functionName);
				auto call = yul::FunctionCall{
					{}, yul::Identifier{{}, functionLabelID}, {}
				};
				expectToken(Token::Comma);
				scanner.next();
				size_t index = size_t(atoi(scanner.currentLiteral().c_str()));
				stack.emplace_back(TemporarySlot{
					m_functions.emplace(functionLabelID, call).first->second,
					index
				});
				expectToken(Token::RBrack);
			}
			else if (literal.find("0x") != std::string::npos || scanner.currentToken() == Token::Number)
			{
				stack.emplace_back(LiteralSlot{u256(literal)});
			}
			else if (literal == "JUNK")
			{
				stack.emplace_back(JunkSlot());
			}
			else if (literal == "GHOST")
			{
				expectToken(Token::LBrack);
				scanner.next(); // read number of ghost variables as ghostVariableId
				std::string ghostVariableId = scanner.currentLiteral();
				auto const ghostID = m_labelRegistryBuilder.addGhost();
				Scope::Variable ghostVar = Scope::Variable{ghostID};
				stack.emplace_back(VariableSlot{
					m_variables.insert(std::make_pair(ghostVar.name, ghostVar)).first->second
				});
				expectToken(Token::RBrack);
			}
			else
			{
				auto const labelID = m_labelRegistryBuilder.define(literal);
				Scope::Variable var = Scope::Variable{labelID};
				stack.emplace_back(VariableSlot{
					m_variables.emplace(labelID, var).first->second
				});
			}
			scanner.next();
		}
		return scanner.currentToken() == Token::RBrack;
	};

	if (!parseStack(m_sourceStack))
		return false;
	scanner.next();
	return parseStack(m_targetStack);
}

StackShufflingTest::StackShufflingTest(std::string const& _filename):
	TestCase(_filename)
{
	processSettings();
	m_source = m_reader.source();
	m_expectation = m_reader.simpleExpectations();
}

void StackShufflingTest::processSettings()
{
	std::string depthString = m_reader.stringSetting("maximumStackDepth", "16");
	std::optional<unsigned> depth = toUnsignedInt(depthString);
	if (!depth.has_value())
		BOOST_THROW_EXCEPTION(std::runtime_error{"Invalid maximum stack depth: \"" + depthString + "\""});
	m_maximumStackDepth = *depth;
}

TestCase::TestResult StackShufflingTest::run(std::ostream& _stream, std::string const& _linePrefix, bool _formatted)
{
	auto const& dialect = CommonOptions::get().evmDialect();
	if (!parse(m_source))
	{
		AnsiColorized(_stream, _formatted, {formatting::BOLD, formatting::RED}) << _linePrefix << "Error parsing source." << std::endl;
		return TestResult::FatalError;
	}

	CFG cfg;
	cfg.labels = std::make_unique<ASTLabelRegistry>(m_labelRegistryBuilder.build());
	std::ostringstream output;
	size_t operations = 0;
	createStackLayout(
		m_sourceStack,
		m_targetStack,
		[&](unsigned _swapDepth) // swap
		{
			++operations;
			output << stackToString(m_sourceStack, cfg, dialect) << std::endl;
			output << "SWAP" << _swapDepth << std::endl;
		},
		[&](StackSlot const& _slot) // dupOrPush
		{
			++operations;
			output << stackToString(m_sourceStack, cfg, dialect) << std::endl;
			if (canBeFreelyGenerated(_slot))
				output << "PUSH " << stackSlotToString(_slot, cfg, dialect) << std::endl;
			else
			{
				if (auto depth = util::findOffset(m_sourceStack | ranges::views::reverse, _slot))
					output << "DUP" << *depth + 1 << std::endl;
				else
					BOOST_THROW_EXCEPTION(std::runtime_error("Invalid DUP operation."));
			}
		},
		[&](){ // pop
			++operations;
			output << stackToString(m_sourceStack, cfg, dialect) << std::endl;
			output << "POP" << std::endl;
		},
		m_maximumStackDepth
    );

	output << stackToString(m_sourceStack, cfg, dialect) << std::endl;
	output << operations << " operations" << std::endl;
	m_obtainedResult = output.str();

	return checkResult(_stream, _linePrefix, _formatted);
}
