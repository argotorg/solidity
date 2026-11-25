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

#include <libsolidity/interface/Ethdebug.h>

#include <libsolidity/ast/AST.h>
#include <libsolidity/ast/CallGraph.h>
#include <libsolidity/ast/Types.h>
#include <libsolidity/codegen/ir/IRVariable.h>
#include <libsolidity/interface/EthdebugPointerTemplateRegistry.h>
#include <libsolidity/interface/EthdebugTypeRegistry.h>
#include <liblangutil/Exceptions.h>

#include <libsolutil/JSON.h>

#include <functional>
#include <memory>
#include <optional>
#include <set>
#include <tuple>
#include <utility>
#include <vector>
#include <variant>

using namespace solidity;
using namespace solidity::frontend;
using solidity::langutil::SemanticDebugDataTable;
using solidity::langutil::SemanticDebugScope;
using solidity::langutil::SemanticDebugVariable;
using solidity::langutil::SemanticDebugVariablePhase;
using solidity::frontend::ethdebug::TypeRegistry;

namespace schema = solidity::langutil::ethdebug::schema;

namespace
{

/// Calls @a _visit for every function and modifier compiled into @a _contract:
/// the callable nodes in its creation and deployed call graphs.
void forEachCompiledCallable(
	ContractDefinition const& _contract,
	std::function<void(CallableDeclaration const&)> const& _visit
)
{
	std::set<CallableDeclaration const*, ASTNode::CompareByID> callables;
	for (CallGraph const* callGraph: {
		_contract.annotation().creationCallGraph->get(),
		_contract.annotation().deployedCallGraph->get(),
	})
		for (auto const& [caller, callees]: callGraph->edges)
		{
			if (auto const* callable = std::get_if<CallableDeclaration const*>(&caller);
				callable != nullptr
			)
				callables.insert(*callable);
			for (CallGraph::Node const& callee: callees)
				if (auto const* callable = std::get_if<CallableDeclaration const*>(&callee);
					callable != nullptr
				)
					callables.insert(*callable);
		}
	for (CallableDeclaration const* callable: callables)
		_visit(*callable);
}

/// The pointer of a value on the stack, held in the generated Yul locals of
/// @a _variable, which stand in for stack slots until Yul is compiled to EVM:
/// a region of the local for a value in one stack slot, the pointer of its
/// only stack item for a value with one, otherwise a group of the pointers of
/// its stack items, named after the items and prefixed with @a _name.
/// @returns nothing for a value without stack slots.
std::optional<schema::Pointer> stackPointer(IRVariable const& _variable, std::optional<std::string> const& _name)
{
	std::vector<std::tuple<std::string, Type const*>> const& items = _variable.type().stackItems();
	if (items.empty())
		return std::nullopt;
	if (items.size() == 1 && !std::get<1>(items.front()))
		return schema::Pointer{schema::Pointer::Region{
			_name,
			schema::Pointer::Location::Stack,
			schema::Pointer::Expression{schema::Pointer::YulLocal{_variable.name()}},
			std::nullopt,
			std::nullopt,
		}};
	if (items.size() == 1)
		return stackPointer(_variable.part(std::get<0>(items.front())), _name);

	std::vector<schema::Pointer> members;
	for (auto const& [itemName, itemType]: items)
	{
		solAssert(itemType && !itemName.empty(), "A stack item of a value in several slots has a name and a type.");
		std::string const name = _name.has_value() ? *_name + "-" + itemName : itemName;
		if (std::optional<schema::Pointer> member = stackPointer(_variable.part(itemName), name);
			member.has_value()
		)
			members.emplace_back(std::move(*member));
	}
	if (members.empty())
		return std::nullopt;
	return schema::Pointer{schema::Pointer::Group{std::move(members)}};
}

/// The record of a parameter or return variable: materialized in the Yul
/// locals of its stack slots, or optimized out if it has none.
SemanticDebugVariable stackVariableRecord(TypeRegistry& _types, VariableDeclaration const& _variable)
{
	solAssert(_variable.type());
	SemanticDebugVariable record;
	if (!_variable.name().empty())
		record.identifier = _variable.name();
	record.declarationASTID = _variable.id();
	record.declarationSourceRange = _types.buildSourceRange(_variable.location());
	_types.registerTypeDecomposition(*_variable.type());
	record.typeID = TypeRegistry::canonicalizeType(*_variable.type()).identifier();
	if (std::optional<schema::Pointer> pointer = stackPointer(IRVariable{_variable}, std::nullopt);
		pointer.has_value()
	)
	{
		record.phase = SemanticDebugVariablePhase::Materialized;
		record.pointer = std::move(*pointer);
	}
	else
		record.phase = SemanticDebugVariablePhase::OptimizedOut;
	return record;
}

/// The scope record of a function or modifier: its parameters and return
/// variables, in that order.
SemanticDebugScope callableScope(TypeRegistry& _types, CallableDeclaration const& _callable)
{
	SemanticDebugScope scope;
	for (ASTPointer<VariableDeclaration> const& parameter: _callable.parameters())
		scope.variableDefinitions.emplace_back(stackVariableRecord(_types, *parameter));
	// Modifiers have no return parameter list.
	if (_callable.returnParameterList())
		for (ASTPointer<VariableDeclaration> const& returnParameter: _callable.returnParameters())
			scope.variableDefinitions.emplace_back(stackVariableRecord(_types, *returnParameter));
	return scope;
}
}

void ethdebug::Resources::merge(Resources _other)
{
	// TODO: Benchmark these JSON comparisons and consider plain assert() once
	// debug assertions are enabled in our builds.
	for (auto& [id, document]: _other.types)
	{
		auto const [it, inserted] = types.try_emplace(id, std::move(document));
		solAssert(
			inserted || Json(it->second) == Json(document),
			"Conflicting ethdebug types for ID " + id + "."
		);
	}
	for (auto& [name, pointerTemplate]: _other.pointers)
	{
		auto const [it, inserted] = pointers.try_emplace(name, std::move(pointerTemplate));
		solAssert(
			inserted || Json(it->second) == Json(pointerTemplate),
			"Conflicting ethdebug pointer templates for ID " + name + "."
		);
	}
}

SemanticDebugScope ethdebug::stateVariableScope(
	ContractDefinition const& _contract,
	std::map<std::string, unsigned> const& _sourceIndices,
	std::map<int64_t, size_t> const& _immutableOffsets
)
{
	TypeRegistry types{_sourceIndices};
	auto const* typeType = dynamic_cast<TypeType const*>(_contract.type());
	solAssert(typeType, "Contract TypeType expected.");
	auto const* contractType = dynamic_cast<ContractType const*>(typeType->actualType());
	solAssert(contractType, "Contract type expected.");

	SemanticDebugScope scope;
	auto const addStateVariables = [&](DataLocation _dataLocation) {
		for (auto const& [variable, slot, offset]: contractType->linearizedStateVariables(_dataLocation))
		{
			solAssert(!variable->name().empty(), "State variable without a name.");
			SemanticDebugVariable record;
			record.identifier = variable->name();
			record.declarationASTID = variable->id();
			record.declarationSourceRange = types.buildSourceRange(variable->location());
			record.typeID = TypeRegistry::canonicalizeType(*variable->type()).identifier();
			record.phase = SemanticDebugVariablePhase::Materialized;
			record.pointer = PointerTemplateRegistry::buildStateVariablePointer(*variable->type(), _dataLocation, slot, offset);
			scope.variableDefinitions.emplace_back(std::move(record));
		}
	};
	addStateVariables(DataLocation::Storage);
	addStateVariables(DataLocation::Transient);
	// An immutable that the code never reads has no copy in it.
	for (VariableDeclaration const* variable: contractType->immutableVariables())
		if (auto const codeOffset = _immutableOffsets.find(variable->id());
			codeOffset != _immutableOffsets.end()
		)
		{
			SemanticDebugVariable record;
			record.identifier = variable->name();
			record.declarationASTID = variable->id();
			record.declarationSourceRange = types.buildSourceRange(variable->location());
			record.typeID = TypeRegistry::canonicalizeType(*variable->type()).identifier();
			record.phase = SemanticDebugVariablePhase::Materialized;
			record.pointer = PointerTemplateRegistry::buildImmutablePointer(*variable->type(), codeOffset->second);
			scope.variableDefinitions.emplace_back(std::move(record));
		}
	return scope;
}

std::optional<schema::program::Context> ethdebug::programContext(
	SemanticDebugScope _scope,
	Resources const& _resources
)
{
	std::vector<schema::program::Context::Variable> variables;
	for (SemanticDebugVariable& variable: _scope.variableDefinitions)
	{
		if (variable.phase != SemanticDebugVariablePhase::Materialized || !variable.pointer.has_value())
			continue;
		// A pointer that reads a generated Yul local, or a variable that
		// nothing binds, is only meaningful once the Yul-to-EVM transform has
		// resolved it; the program-level context carries closed pointers. The
		// templates a pointer references are in the resources, their
		// parameters bound by the pointer.
		if (!schema::freeNames(*variable.pointer, _resources.pointers).empty())
			continue;

		schema::program::Context::Variable contextVariable;
		contextVariable.identifier = variable.identifier;
		contextVariable.declaration = variable.declarationSourceRange;
		if (variable.typeID.has_value())
			contextVariable.type = schema::Type::Specifier{schema::Type::Reference{schema::materials::ID{*variable.typeID}}};
		contextVariable.pointer = std::move(variable.pointer);
		variables.emplace_back(std::move(contextVariable));
	}

	if (variables.empty())
		return std::nullopt;
	schema::program::Context context;
	context.variables = std::move(variables);
	return context;
}

ethdebug::Resources ethdebug::resources(ContractDefinition const& _contract, std::map<std::string, unsigned> const& _sourceIndices)
{
	TypeRegistry types{_sourceIndices};

	auto const* typeType = dynamic_cast<TypeType const*>(_contract.type());
	solAssert(typeType, "Contract TypeType expected.");
	auto const* contractType = dynamic_cast<ContractType const*>(typeType->actualType());
	solAssert(contractType, "Contract type expected.");

	PointerTemplateRegistry templates;
	for (ContractDefinition const* base: _contract.annotation().linearizedBaseContracts)
		for (VariableDeclaration const* variable: base->stateVariables())
			types.registerVariableTypes(*variable);

	auto const addPointerTemplates = [&](DataLocation _dataLocation) {
		for (auto const& entry: contractType->linearizedStateVariables(_dataLocation))
		{
			VariableDeclaration const* variable = std::get<0>(entry);
			solAssert(!variable->name().empty(), "State variable without a name.");
			templates.registerType(*variable->type(), _dataLocation);
		}
	};
	addPointerTemplates(DataLocation::Storage);
	addPointerTemplates(DataLocation::Transient);

	forEachCompiledCallable(_contract, [&](CallableDeclaration const& _callable) {
		types.registerCallableTypes(_callable);
		templates.registerVariableTypes(_callable);
	});

	return Resources{
		.types = types.takeDocuments(),
		.pointers = templates.takeTemplates(),
	};
}

SemanticDebugDataTable ethdebug::semanticDebugDataTable(
	ContractDefinition const& _contract,
	std::map<std::string, unsigned> const& _sourceIndices
)
{
	SemanticDebugDataTable table;
	table.setContractName(_contract.name());

	auto const setScope = [&](int64_t _astID, SemanticDebugScope _scope) {
		// A scope without variables has nothing to describe.
		if (!_scope.variableDefinitions.empty())
			table.set({_astID, 0}, std::make_shared<SemanticDebugScope const>(std::move(_scope)));
	};
	setScope(_contract.id(), stateVariableScope(_contract, _sourceIndices));
	TypeRegistry types{_sourceIndices};
	forEachCompiledCallable(_contract, [&](CallableDeclaration const& _callable) {
		setScope(_callable.id(), callableScope(types, _callable));
	});

	Resources contractResources = resources(_contract, _sourceIndices);
	for (auto& [id, document]: contractResources.types)
		table.setType(id, std::move(document));
	for (auto& [id, pointerTemplate]: contractResources.pointers)
		table.setPointerTemplate(id, std::move(pointerTemplate));
	return table;
}
