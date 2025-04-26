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

#include <libsolutil/JSON.h>

#include <string>
#include <string_view>
#include <vector>

namespace solidity::evmasm::test
{

/// Parser for the plain assembly format. The format is meant to be good enough for humans to read
/// while being straightforward to map to the assembly JSON format that solc can import.
///
/// Syntax:
/// - Every line consists of zero or more whitespace-separated tokens.
/// - A token that begins with `//` starts a comment, which extends to the end of the line.
/// - A non-empty line represents a single assembly item.
/// - The name of the item is the first thing on the line and may consist of one or more tokens.
/// - One or more arguments follow the name.
///
/// Supported items:
/// - All instruction names.
/// - PUSH <hex value>
/// - PUSH [tag] <tagID>
/// - tag <tagID>
class PlainAssemblyParser
{
public:
	/// Parses plain assembly format and returns the equivalent assembly JSON.
	/// Errors are reported by throwing runtime_error.
	Json parse(std::string _sourceName, std::string const& _source);

protected:
	struct Token
	{
		std::string_view value; ///< Substring of m_line that represents a complete token.
		size_t position;        ///< Position of the first character of the token within m_line.
	};

	Token const& currentToken() const;
	Token const& nextToken() const;
	bool hasMoreTokens() const { return m_tokenIndex + 1 < m_lineTokens.size(); }

	bool advanceToken();
	std::string_view expectArgument();
	void expectNoMoreArguments();
	void advanceLine(std::string_view _line);

	static std::vector<Token> tokenizeLine(std::string_view _line);
	std::string formatError(std::string_view _message) const;

private:
	std::string m_sourceName;        ///< Name of the file the source comes from.
	size_t m_lineNumber = 0;         ///< The number of the current line within the source, 1-based.
	std::string m_line;              ///< The current line, unparsed.
	std::vector<Token> m_lineTokens; ///< Decomposition of the current line into tokens (does not include comments).
	size_t m_tokenIndex = 0;         ///< Points at a token within m_lineTokens.
};

}
