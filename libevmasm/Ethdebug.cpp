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

#include <libevmasm/Ethdebug.h>

#include <libevmasm/EthdebugSchema.h>

#include <range/v3/algorithm/any_of.hpp>

using namespace solidity;
using namespace solidity::evmasm;
using namespace solidity::evmasm::ethdebug;

namespace
{

schema::program::Instruction::Operation instructionOperation(Assembly const& _assembly, LinkerObject const& _linkerObject, size_t const _start, size_t const _end)
{
	solAssert(_end <= _linkerObject.bytecode.size());
	solAssert(_start < _end);
	schema::program::Instruction::Operation operation;
	operation.mnemonic = instructionInfo(static_cast<Instruction>(_linkerObject.bytecode[_start]), _assembly.evmVersion()).name;
	static size_t constexpr instructionSize = 1;
	if (_start + instructionSize < _end)
	{
		bytes const argumentData(
			_linkerObject.bytecode.begin() + static_cast<std::ptrdiff_t>(_start) + instructionSize,
			_linkerObject.bytecode.begin() + static_cast<std::ptrdiff_t>(_end)
		);
		solAssert(!argumentData.empty());
		operation.arguments = {{schema::data::HexValue{argumentData}}};
	}
	return operation;
}

schema::materials::SourceRange::Range locationRange(langutil::SourceLocation const& _location)
{
	return {
		.length = schema::data::Unsigned{_location.end - _location.start},
		.offset = schema::data::Unsigned{_location.start}
	};
}

schema::materials::Reference sourceReference(unsigned _sourceID)
{
	return {
		.id = schema::materials::ID{_sourceID},
		.type = std::nullopt
	};
}

std::optional<schema::program::Context> instructionContext(Assembly::CodeSection const& _codeSection, size_t _assemblyItemIndex, unsigned _sourceID)
{
	solAssert(_assemblyItemIndex < _codeSection.items.size());
	langutil::SourceLocation const& location = _codeSection.items.at(_assemblyItemIndex).location();
	if (!location.isValid())
		return std::nullopt;

	return schema::program::Context{
		schema::materials::SourceRange{
			.source = sourceReference(_sourceID),
			.range = locationRange(location)
		},
		std::nullopt,
		std::nullopt
	};
}

std::vector<schema::program::Instruction> codeSectionInstructions(Assembly const& _assembly, LinkerObject const& _linkerObject, unsigned const _sourceID, size_t const _codeSectionIndex)
{
	solAssert(_codeSectionIndex < _linkerObject.codeSectionLocations.size());
	solAssert(_codeSectionIndex < _assembly.codeSections().size());
	auto const& locations = _linkerObject.codeSectionLocations[_codeSectionIndex];
	auto const& codeSection = _assembly.codeSections().at(_codeSectionIndex);

	std::vector<schema::program::Instruction> instructions;
	instructions.reserve(codeSection.items.size());

	bool const codeSectionContainsVerbatim = ranges::any_of(
		codeSection.items,
		[](auto const& _instruction) { return _instruction.type() == VerbatimBytecode; }
	);
	solUnimplementedAssert(!codeSectionContainsVerbatim, "Verbatim bytecode is currently not supported by ethdebug.");

	for (auto const& currentInstruction: locations.instructionLocations)
	{
		size_t const start = currentInstruction.start;
		size_t const end = currentInstruction.end;

		// some instructions do not contribute to the bytecode
		if (start == end)
			continue;

		instructions.emplace_back(schema::program::Instruction{
			.offset = schema::data::Unsigned{start},
			.operation = instructionOperation(_assembly, _linkerObject, start, end),
			.context = instructionContext(codeSection, currentInstruction.assemblyItemIndex, _sourceID)
		});
	}

	return instructions;
}

std::vector<schema::program::Instruction> programInstructions(Assembly const& _assembly, LinkerObject const& _linkerObject, unsigned const _sourceID)
{
	auto const numCodeSections = _assembly.codeSections().size();
	solAssert(numCodeSections == _linkerObject.codeSectionLocations.size());

	std::vector<schema::program::Instruction> instructionInfo;
	for (size_t codeSectionIndex = 0; codeSectionIndex < numCodeSections; ++codeSectionIndex)
		instructionInfo += codeSectionInstructions(_assembly, _linkerObject, _sourceID, codeSectionIndex);
	return instructionInfo;
}

} // anonymous namespace

Json ethdebug::program(std::string_view _name, unsigned _sourceID, Assembly const& _assembly, LinkerObject const& _linkerObject)
{
	return schema::Program{
		.compilation = std::nullopt,
		.contract = {
			.name = std::string{_name},
			.definition = {
				.source = {
					.id = {_sourceID},
					.type = std::nullopt
				},
				.range = std::nullopt
			}
		},
		.environment = _assembly.isCreation() ? schema::Program::Environment::CREATE : schema::Program::Environment::CALL,
		.context = std::nullopt,
		.instructions = programInstructions(_assembly, _linkerObject, _sourceID)
	};
}

Json ethdebug::resources(std::vector<std::string> const& _sources, std::string const& _version)
{
	Json sources = Json::array();
	for (size_t id = 0; id < _sources.size(); ++id)
	{
		Json source = Json::object();
		source["id"] = id;
		source["path"] = _sources[id];
		sources.push_back(source);
	}
	Json result = Json::object();
	result["compilation"] = Json::object();
	result["compilation"]["compiler"] = Json::object();
	result["compilation"]["compiler"]["name"] = "solc";
	result["compilation"]["compiler"]["version"] = _version;
	result["compilation"]["sources"] = sources;
	return result;
}
