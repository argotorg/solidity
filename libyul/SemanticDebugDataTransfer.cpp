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

#include <libyul/SemanticDebugDataTransfer.h>

#include <libyul/AST.h>
#include <libyul/Object.h>
#include <libyul/optimiser/NameCollector.h>

#include <liblangutil/SemanticDebugData.h>
#include <liblangutil/SemanticDebugDataAnalysis.h>
#include <liblangutil/SemanticDebugDataTable.h>

#include <memory>
#include <map>
#include <set>
#include <type_traits>
#include <string>
#include <utility>
#include <variant>
#include <vector>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::langutil;

namespace
{

template<typename>
constexpr bool isVariant = false;
template<typename... Ts>
constexpr bool isVariant<std::variant<Ts...>> = true;

template<typename>
constexpr bool isUniquePtr = false;
template<typename T>
constexpr bool isUniquePtr<std::unique_ptr<T>> = true;

template<typename>
constexpr bool isVector = false;
template<typename T>
constexpr bool isVector<std::vector<T>> = true;

/// Visits the debug data of every node of a Yul AST, including the names in
/// declarations, parameter and return variable lists, which ASTWalker does not
/// visit. Constness is a template parameter so that the same traversal reads
/// a const AST and rewrites a mutable one.
template<typename Visitor>
class DebugDataVisitor
{
public:
	explicit DebugDataVisitor(Visitor _visitor): m_visitor(std::move(_visitor)) {}

	template<typename BlockT>
	void operator()(BlockT& _block) { visitNode(_block); }

private:
	template<typename T>
	void visitNode(T& _node)
	{
		using Node = std::remove_const_t<T>;
		if constexpr (isVariant<Node>)
			std::visit([&](auto& _alternative) { visitNode(_alternative); }, _node);
		else if constexpr (isUniquePtr<Node>)
		{
			if (_node)
				visitNode(*_node);
		}
		else if constexpr (isVector<Node>)
		{
			for (auto& element: _node)
				visitNode(element);
		}
		else
		{
			if constexpr (requires { _node.debugData; })
				m_visitor(_node.debugData);
			visitChildren(_node);
		}
	}

	template<typename T>
	void visitChildren(T& _node)
	{
		if constexpr (requires { _node.statements; })
			visitNode(_node.statements);
		if constexpr (requires { _node.expression; })
			visitNode(_node.expression);
		if constexpr (requires { _node.value; })
			visitNode(_node.value);
		if constexpr (requires { _node.variables; })
			visitNode(_node.variables);
		if constexpr (requires { _node.variableNames; })
			visitNode(_node.variableNames);
		if constexpr (requires { _node.parameters; })
			visitNode(_node.parameters);
		if constexpr (requires { _node.returnVariables; })
			visitNode(_node.returnVariables);
		if constexpr (requires { _node.body; })
			visitNode(_node.body);
		if constexpr (requires { _node.condition; })
			visitNode(_node.condition);
		if constexpr (requires { _node.cases; })
			visitNode(_node.cases);
		if constexpr (requires { _node.pre; })
			visitNode(_node.pre);
		if constexpr (requires { _node.post; })
			visitNode(_node.post);
		if constexpr (requires { _node.functionName; })
			visitNode(_node.functionName);
		if constexpr (requires { _node.arguments; })
			visitNode(_node.arguments);
	}

	Visitor m_visitor;
};

langutil::SemanticDebugDataTable::Key keyOf(langutil::DebugData const& _debugData)
{
	return {*_debugData.astID, _debugData.astIDInstance.value_or(0)};
}

std::set<std::string> declaredVariableNames(Block const& _root)
{
	std::set<std::string> names;
	for (auto const& name: NameCollector(_root, NameCollector::OnlyVariables).names())
		names.insert(name.str());
	return names;
}

/// Whether every name that @a _pointer reads and nothing binds is a variable
/// declared in the current Yul code.
bool pointerDependenciesPresent(
	SemanticDebugPointer const& _pointer,
	std::set<std::string> const& _yulNames,
	SemanticDebugDataTable const& _table
)
{
	for (std::string const& name: semanticDebugPointerFreeNames(_pointer, _table))
		if (!_yulNames.count(name))
			return false;
	return true;
}

/// Marking a value unavailable is always sound, while keeping a pointer that
/// no longer describes the value is not: a materialized variable whose pointer
/// reads a Yul name that no longer exists becomes optimized-out, and so does
/// an update that would rebind it to such a pointer.
SemanticDebugScope::ConstPtr withLostPointersInvalidated(
	SemanticDebugScope::ConstPtr const& _scope,
	std::set<std::string> const& _yulNames,
	SemanticDebugDataTable const& _table
)
{
	if (!_scope)
		return nullptr;

	SemanticDebugScope result = *_scope;
	bool changed = false;
	for (SemanticDebugVariable& variable: result.variableDefinitions)
		if (
			variable.phase == SemanticDebugVariablePhase::Materialized &&
			variable.pointer &&
			!pointerDependenciesPresent(*variable.pointer, _yulNames, _table)
		)
		{
			variable.phase = SemanticDebugVariablePhase::OptimizedOut;
			variable.pointer = std::nullopt;
			changed = true;
		}
	for (SemanticDebugVariableUpdate& update: result.variableUpdates)
		if (update.pointer && !pointerDependenciesPresent(*update.pointer, _yulNames, _table))
		{
			update.phase = SemanticDebugVariablePhase::OptimizedOut;
			update.pointer = std::nullopt;
			changed = true;
		}

	if (!changed)
		return _scope;
	return std::make_shared<SemanticDebugScope const>(std::move(result));
}

void applySemanticDebugDataToCode(Object& _object, SemanticDebugDataTable& _table)
{
	std::set<std::string> const yulNames = declaredVariableNames(_object.code()->root());
	// Records are checked once per object and key, then attached to every
	// node carrying that key and written back to the table.
	std::map<SemanticDebugDataTable::Key, SemanticDebugScope::ConstPtr> attached;
	DebugDataVisitor rewriter{[&](langutil::DebugData::ConstPtr& _debugData) {
		if (!_debugData || !_debugData->astID)
			return;

		SemanticDebugDataTable::Key const key = keyOf(*_debugData);
		auto scope = attached.find(key);
		if (scope == attached.end())
		{
			SemanticDebugScope::ConstPtr record = _table.find(key);
			if (!record)
				return;
			scope = attached.emplace(key, withLostPointersInvalidated(record, yulNames, _table)).first;
		}

		_debugData = langutil::DebugData::create(
			_debugData->nativeLocation,
			_debugData->originLocation,
			_debugData->astID,
			_debugData->astIDInstance,
			scope->second
		);
	}};
	// The AST is owned mutably by the object; this is the one place that
	// rewrites its debug data in place.
	rewriter(const_cast<Block&>(_object.code()->root()));

	for (auto const& [key, scope]: attached)
		_table.set(key, scope);
}

}

void yul::collectSemanticDebugData(Object const& _object, SemanticDebugDataTable& _table)
{
	if (_object.hasCode())
	{
		DebugDataVisitor collector{[&](langutil::DebugData::ConstPtr const& _debugData) {
			if (_debugData && _debugData->astID && _debugData->semanticDebugScope)
				_table.set(keyOf(*_debugData), _debugData->semanticDebugScope);
		}};
		collector(_object.code()->root());
	}

	for (auto const& subNode: _object.subObjects)
		if (auto const* subObject = dynamic_cast<Object const*>(subNode.get()))
			collectSemanticDebugData(*subObject, _table);
}

void yul::applySemanticDebugData(Object& _object, SemanticDebugDataTable& _table)
{
	if (_object.hasCode())
		applySemanticDebugDataToCode(_object, _table);

	for (auto const& subNode: _object.subObjects)
		if (auto* subObject = dynamic_cast<Object*>(subNode.get()))
			applySemanticDebugData(*subObject, _table);
}
