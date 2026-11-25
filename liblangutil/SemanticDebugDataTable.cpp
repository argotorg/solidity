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

#include <liblangutil/SemanticDebugDataTable.h>

#include <liblangutil/Exceptions.h>

#include <libsolutil/JSON.h>

using namespace solidity;
using namespace solidity::langutil;
using namespace solidity::langutil::ethdebug;

SemanticDebugDataTable::SemanticDebugDataTable(SemanticDebugDataTable const& _other)
{
	merge(_other);
}

SemanticDebugDataTable& SemanticDebugDataTable::operator=(SemanticDebugDataTable const& _other)
{
	SemanticDebugDataTable copy{_other};
	*this = std::move(copy);
	return *this;
}

void SemanticDebugDataTable::merge(SemanticDebugDataTable const& _other)
{
	if (this == &_other)
		return;
	if (_other.m_contractName.has_value())
		m_contractName = _other.m_contractName;
	for (auto const& [id, scope]: _other.m_scopes)
		m_scopes[id] = scope;
	// Schema nodes uniquely own their children; rebuild resource trees when copying a table.
	for (auto const& [id, document]: _other.m_types)
		if (
			auto const existing = m_types.find(id);
			existing != m_types.end()
		)
			solAssert(Json(existing->second) == Json(document), "Conflicting ethdebug types for ID " + id + ".");
		else
			m_types.emplace(id, schema::typeFromJSON(Json(document), "type"));
	for (auto const& [name, definition]: _other.m_pointerTemplates)
		if (
			auto const existing = m_pointerTemplates.find(name);
			existing != m_pointerTemplates.end()
		)
			solAssert(Json(existing->second) == Json(definition), "Conflicting ethdebug pointer templates for ID " + name + ".");
		else
			m_pointerTemplates.emplace(name, schema::templateFromJSON(Json(definition), "pointer template"));
}
