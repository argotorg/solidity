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

#include <libsmtutil/SMTLib2Interface.h>

#include <libsmtutil/Exceptions.h>

#include <boost/algorithm/string/join.hpp>

#include <range/v3/view/zip.hpp>

#include <sstream>
#include <memory>
#include <stdexcept>
#include <string>
#include <utility>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::smtutil;

void SMTLib2Commands::push() {
	m_frameLimits.push_back(m_commands.size());
}

void SMTLib2Commands::pop() {
	smtAssert(!m_commands.empty());
	auto limit = m_frameLimits.back();
	m_frameLimits.pop_back();
	while (m_commands.size() > limit)
		m_commands.pop_back();
}

std::string SMTLib2Commands::toString() const {
	return boost::algorithm::join(m_commands, "\n");
}

void SMTLib2Commands::clear() {
	m_commands.clear();
	m_frameLimits.clear();
}

void SMTLib2Commands::assertion(std::string _expr) {
	m_commands.push_back("(assert " + std::move(_expr) + ')');
}

void SMTLib2Commands::setOption(std::string _name, std::string _value)
{
	m_commands.push_back("(set-option :" + std::move(_name) + ' ' + std::move(_value) + ')');
}

void SMTLib2Commands::setLogic(std::string _logic)
{
	m_commands.push_back("(set-logic " + std::move(_logic) + ')');
}

void SMTLib2Commands::declareVariable(std::string _name, std::string _sort)
{
	m_commands.push_back("(declare-fun |" + std::move(_name) + "| () " + std::move(_sort) + ')');
}

void SMTLib2Commands::declareFunction(std::string const& _name, std::vector<std::string> const& _domain, std::string const& _codomain)
{
	std::stringstream ss;
	ss << "(declare-fun |" << _name << "| " << '(' << boost::join(_domain, " ")
		<< ')' << ' ' << _codomain << ')';
	m_commands.push_back(ss.str());
}

void SMTLib2Commands::declareTuple(
	std::string const& _name,
	std::vector<std::string> const& _memberNames,
	std::vector<std::string> const& _memberSorts
)
{
	auto quotedName = '|' + _name + '|';
	std::stringstream ss;
	ss << "(declare-datatypes ((" << quotedName << " 0)) (((" << quotedName;
	for (auto && [memberName, memberSort]: ranges::views::zip(_memberNames, _memberSorts))
		ss << " (|" << memberName << "| " << memberSort << ")";
	ss << "))))";
	auto declaration = ss.str();
	m_commands.push_back(ss.str());
}
