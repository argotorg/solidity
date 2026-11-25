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

#include <liblangutil/SemanticDebugDataSerialization.h>

#include <liblangutil/EthdebugJson.h>
#include <liblangutil/Exceptions.h>

#include <libsolutil/Visitor.h>

#include <cctype>
#include <charconv>
#include <set>
#include <string>
#include <string_view>
#include <system_error>
#include <utility>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::langutil::ethdebug;

namespace
{

using Phase = SemanticDebugVariablePhase;

std::string appendMemberToPath(std::string_view _path, std::string_view _name)
{
	return std::string(_path) + "." + std::string(_name);
}

std::string appendIndexToPath(std::string_view _path, size_t _index)
{
	return std::string(_path) + "[" + std::to_string(_index) + "]";
}

/// Phase values use the compiler's dash-separated convention for
/// enumeration values, like `ast-id` in the debug info selection.
constexpr std::pair<Phase, std::string_view> phaseNames[]{
	{Phase::Materialized, "materialized"},
	{Phase::Computed, "computed"},
	{Phase::OptimizedOut, "optimized-out"},
};

std::string_view phaseName(Phase _phase)
{
	for (auto const& [phase, name]: phaseNames)
		if (phase == _phase)
			return name;
	solAssert(false);
	unreachable();
}

Phase phaseFromJSON(Json const& _json, std::string_view _path)
{
	std::string const name = requireValueOfType<std::string>(_json, _path);
	for (auto const& [phase, phaseName]: phaseNames)
		if (name == phaseName)
			return phase;
	solThrow(JsonValidationError, std::string(_path) + " has the unknown value \"" + name + "\".");
}

/// A materialized variable has a pointer; a computed or optimized-out
/// variable does not.
void requirePhaseConsistency(std::optional<Phase> _phase, bool _hasPointer, std::string_view _path)
{
	if (!_phase.has_value())
		return;
	if (*_phase == Phase::Materialized && !_hasPointer)
		solThrow(JsonValidationError, std::string(_path) + " is materialized but has no pointer.");
	if (*_phase != Phase::Materialized && _hasPointer)
		solThrow(JsonValidationError, std::string(_path) + " is " + std::string(phaseName(*_phase)) + " but has a pointer.");
}

// Writing

Json variableToJSON(SemanticDebugVariable const& _variable)
{
	solAssert(!_variable.identifier.has_value() || !_variable.identifier->empty(), "Variable identifier must not be empty.");
	solAssert((_variable.phase == Phase::Materialized) == _variable.pointer.has_value(), "Variable phase and pointer disagree.");
	Json result = Json::object();
	if (_variable.identifier.has_value())
		result["identifier"] = *_variable.identifier;
	if (_variable.declarationASTID.has_value())
		result["declarationASTID"] = *_variable.declarationASTID;
	if (_variable.declarationSourceRange.has_value())
		result["declarationSourceRange"] = *_variable.declarationSourceRange;
	if (_variable.typeID.has_value())
		result["typeID"] = *_variable.typeID;
	result["phase"] = phaseName(_variable.phase);
	if (_variable.pointer.has_value())
		result["pointer"] = *_variable.pointer;
	return result;
}

Json variableUpdateToJSON(SemanticDebugVariableUpdate const& _update)
{
	solAssert(_update.phase.has_value() || _update.pointer.has_value(), "A variable update must change the phase or the pointer.");
	solAssert(!_update.phase.has_value() || (*_update.phase == Phase::Materialized) == _update.pointer.has_value(), "Update phase and pointer disagree.");
	Json result{{"variableASTID", _update.variableASTID}};
	if (_update.phase.has_value())
		result["phase"] = phaseName(*_update.phase);
	if (_update.pointer.has_value())
		result["pointer"] = *_update.pointer;
	return result;
}

Json scopeToJSON(SemanticDebugScope const& _scope)
{
	Json result{{"variableDefinitions", Json::array()}};
	for (SemanticDebugVariable const& variable: _scope.variableDefinitions)
		result["variableDefinitions"].emplace_back(variableToJSON(variable));
	// Omitted while empty, which is all code generation produces: only
	// optimizer passes emit updates.
	if (!_scope.variableUpdates.empty())
	{
		result["variableUpdates"] = Json::array();
		for (SemanticDebugVariableUpdate const& update: _scope.variableUpdates)
			result["variableUpdates"].emplace_back(variableUpdateToJSON(update));
	}
	return result;
}

// Reading

/// The keys of the two-level scope map are the canonical decimal forms of
/// the AST ID and the instance: an optional sign, digits without leading
/// zeros, within the 64-bit range.
int64_t parseDecimalKey(std::string const& _text, std::string_view _path)
{
	std::string_view digits = _text;
	bool const negative = !digits.empty() && digits.front() == '-';
	if (negative)
		digits.remove_prefix(1);
	bool canonical = !digits.empty() && (digits == "0" ? !negative : digits.front() != '0');
	for (char const digit: digits)
		if (!std::isdigit(static_cast<unsigned char>(digit)))
			canonical = false;
	if (!canonical)
		solThrow(JsonValidationError, std::string(_path) + " has the key \"" + _text + "\", which is not a decimal integer.");

	int64_t value = 0;
	auto const [end, error] = std::from_chars(_text.data(), _text.data() + _text.size(), value);
	if (error != std::errc{} || end != _text.data() + _text.size())
		solThrow(JsonValidationError, std::string(_path) + " has the key \"" + _text + "\", which is out of range.");
	return value;
}

constexpr schema::Pointer::ReadOptions sidecarPointers{.internalExpressions = true};

std::optional<schema::Pointer> readOptionalPointer(Json const& _json, std::string_view _path)
{
	if (Json const* pointer = checkAndFindMember(_json, "pointer", _path))
		return schema::pointerFromJSON(*pointer, appendMemberToPath(_path, "pointer"), sidecarPointers);
	return std::nullopt;
}

SemanticDebugVariable variableFromJSON(Json const& _json, std::string_view _path)
{
	requireOnlyMembers(_json, {"identifier", "declarationASTID", "declarationSourceRange", "typeID", "phase", "pointer"}, _path);
	SemanticDebugVariable variable;
	variable.identifier = checkAndReadOptionalMember<std::string>(_json, "identifier", _path);
	if (variable.identifier.has_value() && variable.identifier->empty())
		solThrow(JsonValidationError, appendMemberToPath(_path, "identifier") + " must not be empty.");
	variable.declarationASTID = checkAndReadOptionalMember<int64_t>(_json, "declarationASTID", _path);
	if (Json const* range = checkAndFindMember(_json, "declarationSourceRange", _path))
		variable.declarationSourceRange = schema::materials::sourceRangeFromJSON(*range, appendMemberToPath(_path, "declarationSourceRange"));
	variable.typeID = checkAndReadOptionalMember<std::string>(_json, "typeID", _path);
	variable.phase = phaseFromJSON(requireMember(_json, "phase", _path), appendMemberToPath(_path, "phase"));
	variable.pointer = readOptionalPointer(_json, _path);
	requirePhaseConsistency(variable.phase, variable.pointer.has_value(), _path);
	return variable;
}

SemanticDebugVariableUpdate variableUpdateFromJSON(Json const& _json, std::string_view _path)
{
	requireOnlyMembers(_json, {"variableASTID", "phase", "pointer"}, _path);
	SemanticDebugVariableUpdate update;
	update.variableASTID = requireMemberOfType<int64_t>(_json, "variableASTID", _path);
	if (Json const* phase = checkAndFindMember(_json, "phase", _path))
		update.phase = phaseFromJSON(*phase, appendMemberToPath(_path, "phase"));
	update.pointer = readOptionalPointer(_json, _path);
	if (!update.phase.has_value() && !update.pointer.has_value())
		solThrow(JsonValidationError, std::string(_path) + " must change the phase or the pointer.");
	requirePhaseConsistency(update.phase, update.pointer.has_value(), _path);
	return update;
}

SemanticDebugScope scopeFromJSON(Json const& _json, std::string_view _path)
{
	requireOnlyMembers(_json, {"variableDefinitions", "variableUpdates"}, _path);
	SemanticDebugScope scope;
	Json const& variables = requireMember(_json, "variableDefinitions", _path);
	std::string const variablesPath = appendMemberToPath(_path, "variableDefinitions");
	requireArray(variables, variablesPath);
	for (size_t index = 0; index < variables.size(); ++index)
		scope.variableDefinitions.emplace_back(variableFromJSON(variables.at(index), appendIndexToPath(variablesPath, index)));
	if (Json const* updates = checkAndFindMember(_json, "variableUpdates", _path))
	{
		std::string const updatesPath = appendMemberToPath(_path, "variableUpdates");
		requireArray(*updates, updatesPath);
		for (size_t index = 0; index < updates->size(); ++index)
			scope.variableUpdates.emplace_back(variableUpdateFromJSON(updates->at(index), appendIndexToPath(updatesPath, index)));
	}
	return scope;
}

/// A template reference must resolve against a local templates block in the
/// same pointer document or against the sidecar's pointer table.
void requireResolvableTemplateReferences(
	schema::Pointer const& _pointer,
	std::set<std::string> const& _localTemplates,
	SemanticDebugDataTable const& _table,
	std::string const& _path
)
{
	using Pointer = schema::Pointer;
	auto const recurse = [&](std::unique_ptr<Pointer const> const& _sub, std::string const& _subPath) {
		if (_sub != nullptr)
			requireResolvableTemplateReferences(*_sub, _localTemplates, _table, _subPath);
	};
	std::visit(GenericVisitor{
		[&](Pointer::TemplateReference const& _reference)
		{
			if (!_localTemplates.contains(_reference.name) && _table.findPointerTemplate(_reference.name) == nullptr)
				solThrow(JsonValidationError, _path + " references the unknown pointer template \"" + _reference.name + "\".");
		},
		[&](Pointer::Templates const& _templates)
		{
			std::set<std::string> localTemplates = _localTemplates;
			for (auto const& [templateName, definition]: _templates.templates)
			{
				recurse(definition.body, appendMemberToPath(appendMemberToPath(_path, "templates"), templateName));
				localTemplates.insert(templateName);
			}
			requireResolvableTemplateReferences(*_templates.in, localTemplates, _table, appendMemberToPath(_path, "in"));
		},
		[&](Pointer::Group const& _group)
		{
			for (size_t index = 0; index < _group.members.size(); ++index)
				requireResolvableTemplateReferences(_group.members[index], _localTemplates, _table, appendIndexToPath(appendMemberToPath(_path, "group"), index));
		},
		[&](Pointer::List const& _list) { recurse(_list.is, appendMemberToPath(appendMemberToPath(_path, "list"), "is")); },
		[&](Pointer::Conditional const& _conditional)
		{
			recurse(_conditional.then, appendMemberToPath(_path, "then"));
			recurse(_conditional.otherwise, appendMemberToPath(_path, "else"));
		},
		[&](Pointer::Scope const& _scope) { recurse(_scope.in, appendMemberToPath(_path, "in")); },
		[](Pointer::Region const&) {},
	}, _pointer.value);
}

void requireResolvableTemplateReferences(SemanticDebugDataTable const& _table)
{
	for (auto const& [templateName, definition]: _table.pointerTemplates())
		requireResolvableTemplateReferences(*definition.body, {}, _table, appendMemberToPath("sidecar.resources.pointers", templateName) + ".for");
	for (auto const& [id, scope]: _table.scopes())
	{
		std::string const path = "sidecar.scopes." + std::to_string(id.astID) + "." + std::to_string(id.instance);
		for (size_t index = 0; index < scope->variableDefinitions.size(); ++index)
			if (auto const& pointer = scope->variableDefinitions[index].pointer;
				pointer.has_value()
			)
				requireResolvableTemplateReferences(*pointer, {}, _table, appendMemberToPath(appendIndexToPath(appendMemberToPath(path, "variableDefinitions"), index), "pointer"));
		for (size_t index = 0; index < scope->variableUpdates.size(); ++index)
			if (auto const& pointer = scope->variableUpdates[index].pointer;
				pointer.has_value()
			)
				requireResolvableTemplateReferences(*pointer, {}, _table, appendMemberToPath(appendIndexToPath(appendMemberToPath(path, "variableUpdates"), index), "pointer"));
	}
}

}

Json langutil::semanticDebugDataToJSON(SemanticDebugDataTable const& _table)
{
	Json result{
		{"format", std::string(SemanticDebugDataFormat)},
		{"version", SemanticDebugDataFormatVersion},
	};
	if (_table.contractName().has_value())
		result["contractName"] = *_table.contractName();

	// Resource tables use the public schemas. Internal expressions belong in scope pointers.
	if (!_table.types().empty() || !_table.pointerTemplates().empty())
	{
		Json types = Json::object();
		for (auto const& [id, document]: _table.types())
			types[id] = document;
		Json pointers = Json::object();
		for (auto const& [name, definition]: _table.pointerTemplates())
		{
			solAssert(!schema::hasInternalExpression(*definition.body), "Resource pointer template contains a compiler-internal expression.");
			pointers[name] = definition;
		}
		result["resources"] = Json{
			{"types", std::move(types)},
			{"pointers", std::move(pointers)},
		};
	}

	// Scope records form a two-level map from the decimal AST ID to the
	// decimal instance, with instance 0 written explicitly. The JSON library
	// orders object members by key, which keeps the output deterministic.
	Json scopes = Json::object();
	for (auto const& [id, scope]: _table.scopes())
	{
		solAssert(scope != nullptr, "Semantic debug data table contains a null scope record.");
		scopes[std::to_string(id.astID)][std::to_string(id.instance)] = scopeToJSON(*scope);
	}
	result["scopes"] = std::move(scopes);
	return result;
}

SemanticDebugDataTable langutil::semanticDebugDataFromJSON(Json const& _json)
{
	std::string const root = "sidecar";
	requireOnlyMembers(_json, {"format", "version", "contractName", "resources", "scopes"}, root);
	std::string const format = requireMemberOfType<std::string>(_json, "format", root);
	if (format != SemanticDebugDataFormat)
		solThrow(JsonValidationError, "Unsupported semantic debug data format \"" + format + "\".");
	unsigned const version = requireMemberOfType<unsigned>(_json, "version", root);
	if (version != SemanticDebugDataFormatVersion)
		solThrow(JsonValidationError, "Unsupported semantic debug data format version " + std::to_string(version) + ".");

	SemanticDebugDataTable table;
	std::optional<std::string> contractName = checkAndReadOptionalMember<std::string>(_json, "contractName", root);
	if (contractName.has_value())
		table.setContractName(std::move(*contractName));

	if (Json const* resources = checkAndFindMember(_json, "resources", root))
	{
		std::string const resourcesPath = appendMemberToPath(root, "resources");
		requireOnlyMembers(*resources, {"types", "pointers"}, resourcesPath);
		if (Json const* types = checkAndFindMember(*resources, "types", resourcesPath))
			for (auto& [id, document]: schema::info::typesFromJSON(*types, appendMemberToPath(resourcesPath, "types")))
				table.setType(id, std::move(document));
		// Pointer templates are public resources, published verbatim: an
		// expression internal to the compiler has no place in them, so the
		// reader does not accept one there.
		if (Json const* pointers = checkAndFindMember(*resources, "pointers", resourcesPath))
			for (auto& [name, definition]: schema::info::pointersFromJSON(*pointers, appendMemberToPath(resourcesPath, "pointers")))
				table.setPointerTemplate(name, std::move(definition));
	}

	Json const& scopes = requireMember(_json, "scopes", root);
	std::string const scopesPath = appendMemberToPath(root, "scopes");
	requireObject(scopes, scopesPath);
	for (auto const& [astIDText, instances]: scopes.items())
	{
		std::string const astIDPath = appendMemberToPath(scopesPath, astIDText);
		int64_t const astID = parseDecimalKey(astIDText, scopesPath);
		requireObject(instances, astIDPath);
		for (auto const& [instanceText, scope]: instances.items())
		{
			int64_t const instance = parseDecimalKey(instanceText, astIDPath);
			if (instance < 0)
				solThrow(JsonValidationError, astIDPath + " has the key \"" + instanceText + "\", which must not be negative.");
			table.set(
				ScopeID{astID, instance},
				std::make_shared<SemanticDebugScope const>(scopeFromJSON(scope, appendMemberToPath(astIDPath, instanceText)))
			);
		}
	}

	requireResolvableTemplateReferences(table);
	return table;
}
