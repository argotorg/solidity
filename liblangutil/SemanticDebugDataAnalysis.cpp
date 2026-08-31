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

#include <liblangutil/SemanticDebugDataAnalysis.h>

#include <map>
#include <memory>

using namespace solidity;
using namespace solidity::langutil;

namespace
{

/// Collects the free names of pointers, resolving template references. The
/// free names of a template are computed once per template, with the
/// template's own parameters bound, and cached; a template that references
/// itself, directly or through other templates, contributes nothing to its
/// own free names.
class FreeNameCollector
{
public:
	explicit FreeNameCollector(SemanticDebugDataTable const& _table): m_table(_table) {}

	std::set<std::string> collect(SemanticDebugPointer const& _pointer)
	{
		std::set<std::string> free;
		std::set<std::string> bound;
		LocalTemplates localTemplates;
		visit(_pointer, bound, localTemplates, free);
		return free;
	}

private:
	using LocalTemplates = std::map<std::string, std::shared_ptr<SemanticDebugPointer const>>;

	void visit(
		SemanticDebugPointerExpression const& _expression,
		std::set<std::string> const& _bound,
		std::set<std::string>& _free
	)
	{
		using Kind = SemanticDebugPointerExpression::Kind;
		// A Yul local is a dependency on the current Yul code by definition;
		// nothing binds it. An unbound variable is a dependency as well.
		if (_expression.kind == Kind::YulLocal && _expression.value)
			_free.insert(*_expression.value);
		else if (_expression.kind == Kind::Variable && _expression.value)
		{
			if (!_bound.count(*_expression.value))
				_free.insert(*_expression.value);
		}
		else
			// Lookups and reads name regions, which live in a separate namespace.
			for (SemanticDebugPointerExpression const& operand: _expression.operands)
				visit(operand, _bound, _free);
	}

	void visit(
		SemanticDebugPointer const& _pointer,
		std::set<std::string>& _bound,
		LocalTemplates& _localTemplates,
		std::set<std::string>& _free
	)
	{
		ScopedNames parameters{_bound, _pointer.expectedParameters};

		for (auto const* expression: {&_pointer.slot, &_pointer.offset, &_pointer.length, &_pointer.count, &_pointer.condition})
			if (expression->has_value())
				visit(**expression, _bound, _free);

		// Scope definitions are ordered: each may reference the earlier ones.
		std::vector<std::string> definedNames;
		for (auto const& [definedName, definedValue]: _pointer.definitions)
		{
			visit(definedValue, _bound, _free);
			if (_bound.insert(definedName).second)
				definedNames.emplace_back(definedName);
		}

		for (SemanticDebugPointer const& member: _pointer.group)
			visit(member, _bound, _localTemplates, _free);

		if (_pointer.listElement)
		{
			ScopedNames index{_bound, _pointer.indexName ? std::vector<std::string>{*_pointer.indexName} : std::vector<std::string>{}};
			visit(*_pointer.listElement, _bound, _localTemplates, _free);
		}

		// Locally defined templates are visible to references inside the target.
		std::vector<std::string> addedTemplates;
		if (_pointer.pointerClass == SemanticDebugPointer::Class::Templates)
			for (auto const& [templateName, definition]: _pointer.templates)
				if (definition && _localTemplates.emplace(templateName, definition).second)
					addedTemplates.emplace_back(templateName);

		if (_pointer.pointerClass == SemanticDebugPointer::Class::TemplateReference && _pointer.templateName)
			for (std::string const& name: freeNamesOfTemplate(*_pointer.templateName, _localTemplates))
				if (!_bound.count(name))
					_free.insert(name);

		for (auto const* subPointer: {&_pointer.thenPointer, &_pointer.elsePointer, &_pointer.scopeTarget})
			if (*subPointer)
				visit(**subPointer, _bound, _localTemplates, _free);

		for (std::string const& templateName: addedTemplates)
			_localTemplates.erase(templateName);
		for (std::string const& definedName: definedNames)
			_bound.erase(definedName);
	}

	/// The free names of a template, with its own parameters bound. Local
	/// templates shadow the table's; results for the table's templates are
	/// cached, results for local ones are recomputed per reference.
	std::set<std::string> freeNamesOfTemplate(std::string const& _name, LocalTemplates& _localTemplates)
	{
		if (m_resolving.count(_name))
			return {};

		SemanticDebugPointer const* definition = nullptr;
		bool fromTable = false;
		if (auto const it = _localTemplates.find(_name); it != _localTemplates.end())
			definition = it->second.get();
		else if ((definition = m_table.findPointerTemplate(_name)))
		{
			fromTable = true;
			if (auto const cached = m_tableTemplateFreeNames.find(_name); cached != m_tableTemplateFreeNames.end())
				return cached->second;
		}
		if (!definition)
			return {};

		m_resolving.insert(_name);
		std::set<std::string> free;
		std::set<std::string> bound;
		visit(*definition, bound, _localTemplates, free);
		m_resolving.erase(_name);

		if (fromTable)
			m_tableTemplateFreeNames.emplace(_name, free);
		return free;
	}

	/// Binds names for the lifetime of the object, restoring the previous
	/// state afterwards.
	class ScopedNames
	{
	public:
		ScopedNames(std::set<std::string>& _bound, std::vector<std::string> const& _names): m_bound(_bound)
		{
			for (std::string const& name: _names)
				if (m_bound.insert(name).second)
					m_added.emplace_back(name);
		}
		~ScopedNames()
		{
			for (std::string const& name: m_added)
				m_bound.erase(name);
		}

	private:
		std::set<std::string>& m_bound;
		std::vector<std::string> m_added;
	};

	SemanticDebugDataTable const& m_table;
	std::set<std::string> m_resolving;
	std::map<std::string, std::set<std::string>> m_tableTemplateFreeNames;
};

bool hasInternalExpression(SemanticDebugPointerExpression const& _expression)
{
	if (_expression.kind == SemanticDebugPointerExpression::Kind::YulLocal)
		return true;
	for (SemanticDebugPointerExpression const& operand: _expression.operands)
		if (hasInternalExpression(operand))
			return true;
	return false;
}

}

std::set<std::string> langutil::semanticDebugPointerFreeNames(
	SemanticDebugPointer const& _pointer,
	SemanticDebugDataTable const& _table
)
{
	return FreeNameCollector{_table}.collect(_pointer);
}

bool langutil::semanticDebugPointerHasInternalExpression(SemanticDebugPointer const& _pointer)
{
	for (auto const* expression: {&_pointer.slot, &_pointer.offset, &_pointer.length, &_pointer.count, &_pointer.condition})
		if (expression->has_value() && hasInternalExpression(**expression))
			return true;
	for (auto const& [definedName, definedValue]: _pointer.definitions)
		if (hasInternalExpression(definedValue))
			return true;
	for (SemanticDebugPointer const& member: _pointer.group)
		if (semanticDebugPointerHasInternalExpression(member))
			return true;
	for (auto const& [templateName, definition]: _pointer.templates)
		if (definition && semanticDebugPointerHasInternalExpression(*definition))
			return true;
	for (auto const* subPointer: {&_pointer.listElement, &_pointer.thenPointer, &_pointer.elsePointer, &_pointer.scopeTarget})
		if (*subPointer && semanticDebugPointerHasInternalExpression(**subPointer))
			return true;
	return false;
}
