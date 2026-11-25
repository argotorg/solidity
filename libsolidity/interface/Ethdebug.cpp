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
#include <libsolidity/interface/EthdebugPointerTemplateRegistry.h>
#include <libsolidity/interface/EthdebugTypeRegistry.h>
#include <liblangutil/Exceptions.h>

#include <libsolutil/JSON.h>

#include <set>
#include <variant>

using namespace solidity;
using namespace solidity::frontend;
using solidity::langutil::SemanticDebugScope;
using solidity::langutil::SemanticDebugVariable;
using solidity::langutil::SemanticDebugVariablePhase;

namespace schema = solidity::langutil::ethdebug::schema;

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
	std::map<std::string, unsigned> const& _sourceIndices
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

	std::set<CallableDeclaration const*, ASTNode::CompareByID> callables;
	for (CallGraph const* callGraph: {
		_contract.annotation().creationCallGraph->get(),
		_contract.annotation().deployedCallGraph->get(),
	})
		for (auto const& [caller, callees]: callGraph->edges)
		{
			if (auto const* callable = std::get_if<CallableDeclaration const*>(&caller))
				callables.insert(*callable);
			for (CallGraph::Node const& callee: callees)
				if (auto const* callable = std::get_if<CallableDeclaration const*>(&callee))
					callables.insert(*callable);
		}
	for (CallableDeclaration const* callable: callables)
	{
		types.registerCallableTypes(*callable);
		templates.registerVariableTypes(*callable);
	}

	return Resources{
		.types = types.takeDocuments(),
		.pointers = templates.takeTemplates(),
	};
}
