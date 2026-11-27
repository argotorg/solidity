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

#include <string>
#include <vector>

namespace solidity::smtutil
{

class SMTLib2Commands
{
public:
	void push();
	void pop();

	void clear();

	void assertion(std::string _expr);

	void setOption(std::string _name, std::string _value);

	void setLogic(std::string _logic);

	void declareVariable(std::string _name, std::string _sort);
	void declareFunction(std::string const& _name, std::vector<std::string> const& _domain, std::string const& _codomain);
	void declareTuple(
		std::string const& _name,
		std::vector<std::string> const& _memberNames,
		std::vector<std::string> const& _memberSorts
	);

	[[nodiscard]] std::string toString() const;
private:
	std::vector<std::string> m_commands;
	std::vector<std::size_t> m_frameLimits;

};

}
