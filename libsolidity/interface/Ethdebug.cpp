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

#include <liblangutil/SemanticDebugDataAnalysis.h>
#include <liblangutil/SemanticDebugDataSerialization.h>

#include <cstdint>
#include <string>
#include <utility>
#include <vector>

using namespace solidity;
using namespace solidity::langutil;
using namespace solidity::frontend;

namespace schema = solidity::evmasm::ethdebug::schema;

namespace
{

/// The declaration range already carries the source ID of the compilation
/// record, so it is published as is.
schema::materials::SourceRange declarationRange(SemanticDebugSourceRange const& _range)
{
	schema::materials::Reference reference;
	reference.id = schema::materials::ID{static_cast<std::uint64_t>(_range.sourceID)};
	reference.type = std::nullopt;

	schema::materials::SourceRange sourceRange;
	sourceRange.source = std::move(reference);
	sourceRange.range = schema::materials::SourceRange::Range{
		.length = schema::data::Unsigned{_range.length},
		.offset = schema::data::Unsigned{_range.offset}
	};
	return sourceRange;
}

}

void ethdebug::Resources::merge(Resources const& _other)
{
	for (auto const& [id, document]: _other.types.items())
		types[id] = document;
	for (auto const& [name, definition]: _other.pointers.items())
		pointers[name] = definition;
}

ethdebug::Resources ethdebug::resources(SemanticDebugDataTable const& _table)
{
	Resources result;
	for (auto const& [id, document]: _table.types())
		result.types[id] = document;
	// Deserialization rejects templates carrying an internal expression, and
	// the producer never puts one into a template, so the writer publishes
	// exactly the sidecar's table.
	for (auto const& [name, definition]: _table.pointerTemplates())
		result.pointers[name] = semanticDebugPointerTemplateToJson(definition);
	return result;
}

std::optional<schema::program::Context> ethdebug::programContext(SemanticDebugDataTable const& _table)
{
	using Class = SemanticDebugPointer::Class;

	std::vector<schema::program::Context::Variable> variables;
	for (auto const& [key, scope]: _table.scopes())
	{
		if (!scope)
			continue;

		for (SemanticDebugVariable const& variable: scope->variableDefinitions)
		{
			if (variable.phase != SemanticDebugVariablePhase::Materialized || !variable.pointer)
				continue;

			// A pointer that reads a generated Yul local, or a variable that
			// nothing binds, is only meaningful once the Yul-to-EVM transform
			// has resolved it; the program-level context carries the closed
			// pointers, i.e. those of the state variables.
			if (!semanticDebugPointerFreeNames(*variable.pointer, _table).empty())
				continue;

			// A template reference is resolved against the table; the template
			// body is inlined, so the reference's renaming of regions does not
			// apply, and the context variable's own identifier names the value.
			SemanticDebugPointer const* pointer = &*variable.pointer;
			if (pointer->pointerClass == Class::TemplateReference)
			{
				pointer = pointer->templateName ? _table.findPointerTemplate(*pointer->templateName) : nullptr;
				if (!pointer)
					continue;
			}

			schema::program::Context::Variable contextVariable;
			contextVariable.identifier = variable.identifier;
			if (variable.declarationSourceRange)
				contextVariable.declaration = declarationRange(*variable.declarationSourceRange);
			// The type resources carry the document; the context references it.
			if (variable.typeID)
				contextVariable.type = Json{{"id", *variable.typeID}};
			if (pointer->expectedParameters.empty())
			{
				Json lowered = semanticDebugPointerToJson(*pointer);
				// The context variable's identifier already names it; a bare
				// top-level region does not need an extra "name" property.
				if (lowered.contains("location"))
					lowered.erase("name");
				contextVariable.pointer = std::move(lowered);
			}
			variables.emplace_back(std::move(contextVariable));
		}
	}

	if (variables.empty())
		return std::nullopt;

	schema::program::Context context;
	context.variables = std::move(variables);
	return context;
}
