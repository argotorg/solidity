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

#include <libevmasm/EthdebugSchema.h>

#include <libsolutil/Numeric.h>
#include <libsolutil/Visitor.h>

using namespace solidity;
using namespace solidity::evmasm::ethdebug;

void schema::data::to_json(Json& _json, HexValue const& _hexValue)
{
	_json = util::toHex(_hexValue.value, util::HexPrefix::Add);
}

void schema::data::to_json(Json& _json, Unsigned const& _unsigned)
{
	std::visit(util::GenericVisitor{
		[&](HexValue const& _hexValue) { _json = _hexValue; },
		[&](std::uint64_t const _value) { _json = _value; }
	}, _unsigned.value);
}

void schema::materials::to_json(Json& _json, ID const& _id)
{
	std::visit(util::GenericVisitor{
		[&](std::string const& _hexValue) { _json = _hexValue; },
		[&](std::uint64_t const _value) { _json = _value; }
	}, _id.value);
}

void schema::materials::to_json(Json& _json, Reference const& _source)
{
	_json["id"] = _source.id;
	if (_source.type)
		_json["type"] = *_source.type == Reference::Type::Compilation ? "compilation" : "source";
}

void schema::materials::to_json(Json& _json, SourceRange::Range const& _range)
{
	_json["length"] = _range.length;
	_json["offset"] = _range.offset;
}


void schema::materials::to_json(Json& _json, SourceRange const& _sourceRange)
{
	_json["source"] = _sourceRange.source;
	if (_sourceRange.range)
		_json["range"] = *_sourceRange.range;
}

void schema::to_json(Json& _json, Program::Contract const& _contract)
{
	if (_contract.name)
		_json["name"] = *_contract.name;
	_json["definition"] = _contract.definition;
}

void schema::program::to_json(Json& _json, Context::Variable const& _contextVariable)
{
	auto const numProperties =
		_contextVariable.identifier.has_value() +
		_contextVariable.declaration.has_value();
	solRequire(numProperties >= 1, EthdebugException, "Context variable has no properties.");
	if (_contextVariable.identifier)
	{
		solRequire(!_contextVariable.identifier->empty(), EthdebugException, "Variable identifier must not be empty.");
		_json["identifier"] = *_contextVariable.identifier;
	}
	if (_contextVariable.declaration)
		_json["declaration"] = *_contextVariable.declaration;
}

void schema::program::to_json(Json& _json, Context const& _context)
{
	solRequire(_context.code.has_value() + _context.remark.has_value() + _context.variables.has_value() >= 1, EthdebugException, "Context needs >=1 properties.");
	if (_context.code)
		_json["code"] = *_context.code;
	if (_context.variables)
	{
		solRequire(!_context.variables->empty(), EthdebugException, "Context variables must not be empty if provided.");
		_json["variables"] = *_context.variables;
	}
	if (_context.remark)
		_json["remark"] = *_context.remark;
}

void schema::program::to_json(Json& _json, Instruction::Operation const& _operation)
{
	_json = { {"mnemonic", _operation.mnemonic} };
	if (!_operation.arguments.empty())
		_json["arguments"] = _operation.arguments;
}

void schema::program::to_json(Json& _json, Instruction const& _instruction)
{
	_json["offset"] = _instruction.offset;
	if (_instruction.operation)
		_json["operation"] = *_instruction.operation;
	if (_instruction.context)
		_json["context"] = *_instruction.context;
}

void schema::to_json(Json& _json, Program const& _program)
{
	if (_program.compilation)
		_json["compilation"] = *_program.compilation;
	_json["contract"] = _program.contract;
	_json["environment"] = _program.environment;
	if (_program.context)
		_json["context"] = *_program.context;
	_json["instructions"] = _program.instructions;
}

void schema::to_json(Json& _json, Program::Environment const& _environment)
{
	switch (_environment)
	{
	case Program::Environment::CALL:
		_json = "call";
		break;
	case Program::Environment::CREATE:
		_json = "create";
		break;
	}
}
