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

#include <libyul/optimiser/VarNameCleaner.h>
#include <libyul/optimiser/OptimizerUtilities.h>
#include <libyul/AST.h>
#include <libyul/Dialect.h>

#include <algorithm>
#include <cctype>
#include <climits>
#include <iterator>
#include <string>
#include <regex>
#include <limits>

using namespace solidity::yul;

VarNameCleaner::VarNameCleaner(
	Block const& _ast,
	Dialect const& _dialect,
	std::set<YulName> _namesToKeep
):
	m_dialect{_dialect},
	m_namesToKeep{std::move(_namesToKeep)},
	m_translatedNames{}
{
	for (auto const& statement: _ast.statements)
		if (std::holds_alternative<FunctionDefinition>(statement))
			m_namesToKeep.insert(std::get<FunctionDefinition>(statement).name);
	m_usedNames = m_namesToKeep;
}

void VarNameCleaner::operator()(FunctionDefinition& _funDef)
{
	yulAssert(!m_insideFunction, "");
	m_insideFunction = true;

	std::set<YulName> globalUsedNames = std::move(m_usedNames);
	m_usedNames = m_namesToKeep;
	std::map<YulName, YulName> globalTranslatedNames;
	swap(globalTranslatedNames, m_translatedNames);
	std::map<YulName, size_t> globalNextSuffix;
	swap(globalNextSuffix, m_nextSuffix);

	renameVariables(_funDef.parameters);
	renameVariables(_funDef.returnVariables);
	ASTModifier::operator()(_funDef);

	swap(globalUsedNames, m_usedNames);
	swap(globalTranslatedNames, m_translatedNames);
	swap(globalNextSuffix, m_nextSuffix);

	m_insideFunction = false;
}

void VarNameCleaner::operator()(VariableDeclaration& _varDecl)
{
	renameVariables(_varDecl.variables);
	ASTModifier::operator()(_varDecl);
}

void VarNameCleaner::renameVariables(std::vector<NameWithDebugData>& _variables)
{
	for (NameWithDebugData& variable: _variables)
	{
		auto newName = findCleanName(variable.name);
		if (newName != variable.name)
		{
			m_translatedNames[variable.name] = newName;
			variable.name = newName;
		}
		m_usedNames.insert(variable.name);
	}
}

void VarNameCleaner::operator()(Identifier& _identifier)
{
	auto name = m_translatedNames.find(_identifier.name);
	if (name != m_translatedNames.end())
		_identifier.name = name->second;
}

YulName VarNameCleaner::findCleanName(YulName const& _name) const
{
	auto newName = stripSuffix(_name);
	if (!isUsedName(newName))
		return newName;

	// Use a per-base-name counter to avoid O(n²) probing when many
	// variables share the same stripped base name.
	size_t& nextSuffix = m_nextSuffix[newName];
	if (nextSuffix == 0)
		nextSuffix = 1;
	for (; nextSuffix < std::numeric_limits<size_t>::max(); ++nextSuffix)
	{
		YulName newNameSuffixed = YulName{newName.str() + "_" + std::to_string(nextSuffix)};
		if (!isUsedName(newNameSuffixed))
		{
			++nextSuffix;
			return newNameSuffixed;
		}
	}
	yulAssert(false, "Exhausted by attempting to find an available suffix.");
}

bool VarNameCleaner::isUsedName(YulName const& _name) const
{
	return isRestrictedIdentifier(m_dialect, _name.str()) || m_usedNames.contains(_name);
}

YulName VarNameCleaner::stripSuffix(YulName const& _name) const
{
	static std::regex const suffixRegex("(_+[0-9]+)+$");

	std::smatch suffixMatch;
	if (regex_search(_name.str(), suffixMatch, suffixRegex))
		return {YulName{suffixMatch.prefix().str()}};
	return _name;
}
