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
/// The semantic debug info side table: scope records keyed by their scope ID,
/// together with the type and pointer template resources they reference.

#pragma once

#include <liblangutil/SemanticDebugData.h>

#include <map>
#include <optional>
#include <string>
#include <utility>

namespace solidity::langutil
{

class SemanticDebugDataTable
{
public:
	using Types = std::map<std::string, ethdebug::schema::Type>;
	using PointerTemplates = std::map<std::string, ethdebug::schema::Pointer::Template>;

	SemanticDebugDataTable() = default;
	/// Copies share immutable scope records and independently own resource trees.
	SemanticDebugDataTable(SemanticDebugDataTable const& _other);
	SemanticDebugDataTable& operator=(SemanticDebugDataTable const& _other);
	SemanticDebugDataTable(SemanticDebugDataTable&&) = default;
	SemanticDebugDataTable& operator=(SemanticDebugDataTable&&) = default;

	void setContractName(std::string _contractName) { m_contractName = std::move(_contractName); }
	std::optional<std::string> const& contractName() const { return m_contractName; }

	void set(ScopeID _id, SemanticDebugScope::ConstPtr _scope) { m_scopes[_id] = std::move(_scope); }
	SemanticDebugScope::ConstPtr find(ScopeID _id) const
	{
		auto const it = m_scopes.find(_id);
		return it == m_scopes.end() ? nullptr : it->second;
	}
	std::map<ScopeID, SemanticDebugScope::ConstPtr> const& scopes() const { return m_scopes; }

	/// Type documents keyed by the compiler's type identifier: the same table
	/// that ethdebug.resources.types publishes.
	void setType(std::string _id, ethdebug::schema::Type _document) { m_types.insert_or_assign(std::move(_id), std::move(_document)); }
	ethdebug::schema::Type const* findType(std::string const& _id) const
	{
		auto const it = m_types.find(_id);
		return it == m_types.end() ? nullptr : &it->second;
	}
	Types const& types() const { return m_types; }

	/// Pointer templates keyed by producer-defined name: the same table that
	/// ethdebug.resources.pointers publishes. Variables reference an entry
	/// with the pointer schema's `template` reference.
	void setPointerTemplate(std::string _name, ethdebug::schema::Pointer::Template _template)
	{
		m_pointerTemplates.insert_or_assign(std::move(_name), std::move(_template));
	}
	ethdebug::schema::Pointer::Template const* findPointerTemplate(std::string const& _name) const
	{
		auto const it = m_pointerTemplates.find(_name);
		return it == m_pointerTemplates.end() ? nullptr : &it->second;
	}
	PointerTemplates const& pointerTemplates() const { return m_pointerTemplates; }

	/// Adds the contract name of @a _other if it has one, and its scope records,
	/// replacing records with the same scope ID. Type and pointer template entries
	/// with the same key must serialize identically.
	/// @warning Within a compilation, the key-to-type and key-to-pointer mappings must
	/// be deterministic and independent of the contract that produced the tables.
	void merge(SemanticDebugDataTable const& _other);

	bool empty() const { return m_scopes.empty() && m_types.empty() && m_pointerTemplates.empty(); }

private:
	std::optional<std::string> m_contractName;
	std::map<ScopeID, SemanticDebugScope::ConstPtr> m_scopes;
	Types m_types;
	PointerTemplates m_pointerTemplates;
};

}
