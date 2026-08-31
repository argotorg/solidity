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
/**
 * The semantic debug info side table: scope records keyed by source AST
 * origin, together with the type and pointer template resources.
 */

#pragma once

#include <liblangutil/SemanticDebugData.h>

#include <libsolutil/JSON.h>

#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <utility>

namespace solidity::langutil
{

/// The semantic debug info side table: scope records keyed by source-language
/// AST origin and generated-scope instance, together with the resource tables
/// (types and pointer templates) that the records reference by ID.
class SemanticDebugDataTable
{
public:
	/// A scope record is identified by the source AST ID together with a scope
	/// instance discriminator. Code generation produces instance 0 only;
	/// passes that clone code give each copy its own instance, so the copies
	/// do not overwrite each other. In Yul text the instance travels in the
	/// `@ast-id-instance` annotation next to `@ast-id`.
	using Key = std::pair<int64_t, int64_t>;

	void setContractName(std::string _contractName) { m_contractName = std::move(_contractName); }
	std::optional<std::string> const& contractName() const { return m_contractName; }

	void set(Key _key, SemanticDebugScope::ConstPtr _scope) { m_scopes[_key] = std::move(_scope); }
	void set(int64_t _astID, SemanticDebugScope::ConstPtr _scope) { set(Key{_astID, 0}, std::move(_scope)); }

	SemanticDebugScope::ConstPtr find(Key _key) const
	{
		auto const it = m_scopes.find(_key);
		return it == m_scopes.end() ? nullptr : it->second;
	}
	SemanticDebugScope::ConstPtr find(int64_t _astID, int64_t _instance = 0) const
	{
		return find(Key{_astID, _instance});
	}

	std::map<Key, SemanticDebugScope::ConstPtr> const& scopes() const { return m_scopes; }

	/// Type documents in the shape of the public ethdebug type schema, keyed
	/// by the compiler's type identifier. This is the only type store: scope
	/// records reference into it by ID, and both the sidecar's resources and
	/// the public ethdebug.resources.types output are this map, verbatim.
	void setType(std::string _id, Json _document) { m_types[std::move(_id)] = std::move(_document); }
	Json const* findType(std::string const& _id) const
	{
		auto const it = m_types.find(_id);
		return it == m_types.end() ? nullptr : &it->second;
	}
	std::map<std::string, Json> const& types() const { return m_types; }

	/// Pointer templates keyed by producer-defined name, mirroring the public
	/// ethdebug.resources.pointers table. Variables reference an entry with the
	/// pointer schema's `template` reference, the same way they reference types.
	void setPointerTemplate(std::string _name, SemanticDebugPointer _template)
	{
		m_pointerTemplates[std::move(_name)] = std::move(_template);
	}
	SemanticDebugPointer const* findPointerTemplate(std::string const& _name) const
	{
		auto const it = m_pointerTemplates.find(_name);
		return it == m_pointerTemplates.end() ? nullptr : &it->second;
	}
	std::map<std::string, SemanticDebugPointer> const& pointerTemplates() const { return m_pointerTemplates; }

	/// Adds the content of @a _other: its contract name if it has one, and its
	/// scope records, types and pointer templates, replacing entries with the
	/// same key.
	void merge(SemanticDebugDataTable const& _other)
	{
		if (_other.m_contractName)
			m_contractName = _other.m_contractName;
		for (auto const& [key, scope]: _other.m_scopes)
			m_scopes[key] = scope;
		for (auto const& [id, document]: _other.m_types)
			m_types[id] = document;
		for (auto const& [name, definition]: _other.m_pointerTemplates)
			m_pointerTemplates[name] = definition;
	}

	bool empty() const { return m_scopes.empty() && m_types.empty() && m_pointerTemplates.empty(); }

private:
	std::optional<std::string> m_contractName;
	std::map<Key, SemanticDebugScope::ConstPtr> m_scopes;
	std::map<std::string, Json> m_types;
	std::map<std::string, SemanticDebugPointer> m_pointerTemplates;
};

} // namespace solidity::langutil
