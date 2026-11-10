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

#include <liblangutil/EthdebugSchema.h>

#include <liblangutil/Common.h>
#include <liblangutil/Exceptions.h>

#include <libsolutil/CommonData.h>
#include <libsolutil/Numeric.h>
#include <libsolutil/Visitor.h>

#include <algorithm>
#include <cctype>
#include <set>
#include <string_view>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::langutil;
using namespace solidity::langutil::ethdebug;

std::map<schema::materials::Reference::Type, std::string> const schema::materials::Reference::typeNames = {
	{Type::Compilation, "compilation"},
	{Type::Source, "source"},
};

std::map<schema::Type::Function::Visibility, std::string> const schema::Type::Function::visibilityNames = {
	{Visibility::Internal, "internal"},
	{Visibility::External, "external"},
};

std::map<schema::Pointer::Constant, std::string> const schema::Pointer::constantNames = {
	{Constant::WordSize, "~wordsize"},
};

std::map<schema::Pointer::Lookup::Property, std::string> const schema::Pointer::Lookup::propertyNames = {
	{Property::Slot, ".slot"},
	{Property::Offset, ".offset"},
	{Property::Length, ".length"},
};

std::map<schema::Pointer::Arithmetic::Operator, std::string> const schema::Pointer::Arithmetic::operatorNames = {
	{Operator::Sum, "~sum"},
	{Operator::Difference, "~difference"},
	{Operator::Product, "~product"},
	{Operator::Quotient, "~quotient"},
	{Operator::Remainder, "~remainder"},
};

std::map<schema::Pointer::Location, std::string> const schema::Pointer::locationNames = {
	{Location::Stack, "stack"},
	{Location::Memory, "memory"},
	{Location::Storage, "storage"},
	{Location::Calldata, "calldata"},
	{Location::Returndata, "returndata"},
	{Location::Transient, "transient"},
	{Location::Code, "code"},
};

std::map<schema::Program::Environment, std::string> const schema::Program::environmentNames = {
	{Environment::CALL, "call"},
	{Environment::CREATE, "create"},
};

schema::Type::Specifier::Specifier(std::unique_ptr<Type const> _type):
	value(std::move(_type))
{
	solAssert(std::get<std::unique_ptr<Type const>>(value), "Type specifier without a type.");
}

schema::Type::Definition::Definition(std::optional<std::string> _name, std::optional<materials::SourceRange> _location):
	name(std::move(_name)),
	location(std::move(_location))
{
	solAssert(name.has_value() || location.has_value(), "Type definition without properties.");
	solAssert(!name.has_value() || !name->empty(), "Type definition with an empty name.");
}

schema::Type::UInt::UInt(unsigned _bits):
	bits(_bits)
{
	solAssert(isValidWidth(bits), "Type width must be a multiple of 8 bits up to 256.");
}

schema::Type::Int::Int(unsigned _bits):
	bits(_bits)
{
	solAssert(isValidWidth(bits), "Type width must be a multiple of 8 bits up to 256.");
}

schema::Type::UFixed::UFixed(unsigned _bits, unsigned _places):
	bits(_bits),
	places(_places)
{
	solAssert(isValidWidth(bits), "Type width must be a multiple of 8 bits up to 256.");
	solAssert(isValidPlaces(places), "Fixed point type must have between 1 and 80 decimal places.");
}

schema::Type::Fixed::Fixed(unsigned _bits, unsigned _places):
	bits(_bits),
	places(_places)
{
	solAssert(isValidWidth(bits), "Type width must be a multiple of 8 bits up to 256.");
	solAssert(isValidPlaces(places), "Fixed point type must have between 1 and 80 decimal places.");
}

bool schema::Pointer::isIdentifier(std::string_view _text)
{
	// A Solidity identifier that may also contain `-`.
	auto const isStart = [](char _c) { return isIdentifierStart(_c) || _c == '-'; };
	auto const isPart = [](char _c) { return isIdentifierPart(_c) || _c == '-'; };
	return !_text.empty() && isStart(_text.front()) && std::all_of(_text.begin(), _text.end(), isPart);
}

bool schema::Pointer::isRegionReference(std::string_view _text)
{
	return _text == "~this" || isIdentifier(_text);
}

schema::Pointer::Variable::Variable(std::string _identifier):
	identifier(std::move(_identifier))
{
	solAssert(isIdentifier(identifier), "Pointer expression variable \"" + identifier + "\" is not an identifier.");
}

schema::Pointer::Lookup::Lookup(Property _property, std::string _region):
	property(_property),
	region(std::move(_region))
{
	solAssert(isRegionReference(region), "Region reference \"" + region + "\" is not an identifier.");
}

schema::Pointer::Read::Read(std::string _region):
	region(std::move(_region))
{
	solAssert(isRegionReference(region), "Region reference \"" + region + "\" is not an identifier.");
}

schema::Pointer::Arithmetic::Arithmetic(Operator _op, Operands _operands):
	op(_op),
	operands(std::move(_operands))
{
	if (op == Operator::Difference || op == Operator::Quotient || op == Operator::Remainder)
		solAssert(operands.size() == 2, "Difference, quotient and remainder take exactly two operands.");
}

schema::Pointer::Resize::Resize(std::optional<std::uint64_t> _size, std::unique_ptr<Expression const> _operand):
	size(_size),
	operand(std::move(_operand))
{
	solAssert(!size.has_value() || *size > 0, "Resize expression needs a positive byte width.");
	solAssert(operand, "Resize expression without an operand.");
}

schema::Pointer::Region::Region(
	std::optional<std::string> _name,
	Location _location,
	std::optional<Expression> _slot,
	std::optional<Expression> _offset,
	std::optional<Expression> _length
):
	name(std::move(_name)),
	location(_location),
	slot(std::move(_slot)),
	offset(std::move(_offset)),
	length(std::move(_length))
{
	if (name.has_value())
		solAssert(isIdentifier(*name), "Region name \"" + *name + "\" is not an identifier.");
	switch (location)
	{
	case Location::Stack:
	case Location::Storage:
	case Location::Transient:
		// Word-oriented locations address by slot.
		solAssert(slot.has_value(), "A stack, storage or transient region must address its slot.");
		break;
	case Location::Memory:
	case Location::Calldata:
	case Location::Returndata:
	case Location::Code:
		// Byte-oriented locations address by offset and length.
		solAssert(!slot.has_value() && offset.has_value() && length.has_value(), "A memory, calldata, returndata or code region must address its offset and length.");
		break;
	}
}

schema::Pointer::Group::Group(std::vector<Pointer> _members):
	members(std::move(_members))
{
	solAssert(!members.empty(), "A group pointer must have at least one member.");
}

schema::Pointer::List::List(Expression _count, std::string _each, std::unique_ptr<Pointer const> _is):
	count(std::move(_count)),
	each(std::move(_each)),
	is(std::move(_is))
{
	solAssert(isIdentifier(each), "List index name \"" + each + "\" is not an identifier.");
	solAssert(is, "List element pointer is missing.");
}

schema::Pointer::Conditional::Conditional(
	Expression _condition,
	std::unique_ptr<Pointer const> _then,
	std::unique_ptr<Pointer const> _otherwise
):
	condition(std::move(_condition)),
	then(std::move(_then)),
	otherwise(std::move(_otherwise))
{
	solAssert(then, "Conditional consequent is missing.");
}

schema::Pointer::Scope::Scope(std::vector<std::pair<std::string, Expression>> _definitions, std::unique_ptr<Pointer const> _in):
	definitions(std::move(_definitions)),
	in(std::move(_in))
{
	solAssert(!definitions.empty(), "A scope pointer must define at least one variable.");
	for (auto const& [variable, expression]: definitions)
		solAssert(isIdentifier(variable), "Scope variable \"" + variable + "\" is not an identifier.");
	solAssert(in, "Scope target pointer is missing.");
}

schema::Pointer::TemplateReference::TemplateReference(std::string _name, std::vector<std::pair<std::string, std::string>> _yields):
	name(std::move(_name)),
	yields(std::move(_yields))
{
	solAssert(isIdentifier(name), "Template name \"" + name + "\" is not an identifier.");
	std::set<std::string> producedNames;
	for (auto const& [producedName, newName]: yields)
	{
		solAssert(producedNames.insert(producedName).second, "Duplicate yielded region name \"" + producedName + "\".");
		solAssert(isIdentifier(producedName), "Yielded region name \"" + producedName + "\" is not an identifier.");
		solAssert(isIdentifier(newName), "Yielded region name \"" + newName + "\" is not an identifier.");
	}
}

schema::Pointer::Template::Template(std::vector<std::string> _expect, std::unique_ptr<Pointer const> _body):
	expect(std::move(_expect)),
	body(std::move(_body))
{
	std::set<std::string> parameters;
	for (std::string const& parameter: expect)
	{
		solAssert(isIdentifier(parameter), "Template parameter \"" + parameter + "\" is not an identifier.");
		solAssert(parameters.insert(parameter).second, "Duplicate template parameter \"" + parameter + "\".");
	}
	solAssert(body, "Pointer template without a body.");
}

schema::Pointer::Templates::Templates(std::vector<std::pair<std::string, Template>> _templates, std::unique_ptr<Pointer const> _in):
	templates(std::move(_templates)),
	in(std::move(_in))
{
	std::set<std::string> names;
	for (auto const& [templateName, definition]: templates)
	{
		solAssert(isIdentifier(templateName), "Template name \"" + templateName + "\" is not an identifier.");
		solAssert(names.insert(templateName).second, "Duplicate template name \"" + templateName + "\".");
	}
	solAssert(in, "Templates target pointer is missing.");
}


void schema::data::to_json(Json& _json, HexValue const& _hexValue)
{
	_json = toHex(_hexValue.value, HexPrefix::Add);
}

void schema::data::to_json(Json& _json, Unsigned const& _unsigned)
{
	std::visit(GenericVisitor{
		[&](HexValue const& _hexValue) { _json = _hexValue; },
		[&](std::uint64_t const _value) { _json = _value; },
	}, _unsigned.value);
}

void schema::data::to_json(Json& _json, Stamp const& _stamp)
{
	_json["schema"] = _stamp.schema;
	_json["version"] = _stamp.version;
}

void schema::materials::to_json(Json& _json, ID const& _id)
{
	std::visit(GenericVisitor{
		[&](std::string const& _hexValue) { _json = _hexValue; },
		[&](std::uint64_t const _value) { _json = _value; },
	}, _id.value);
}

void schema::materials::to_json(Json& _json, Reference const& _source)
{
	_json["id"] = _source.id;
	if (_source.type.has_value())
		_json["type"] = Reference::typeNames.at(*_source.type);
}

void schema::materials::to_json(Json& _json, SourceRange::Range const& _range)
{
	_json["length"] = _range.length;
	_json["offset"] = _range.offset;
}


void schema::materials::to_json(Json& _json, SourceRange const& _sourceRange)
{
	_json["source"] = _sourceRange.source;
	if (_sourceRange.range.has_value())
		_json["range"] = *_sourceRange.range;
}

void schema::materials::to_json(Json& _json, Source const& _source)
{
	_json["id"] = _source.id;
	_json["path"] = _source.path;
	_json["contents"] = _source.contents;
	if (_source.encoding.has_value())
		_json["encoding"] = *_source.encoding;
	_json["language"] = _source.language;
}

void schema::materials::to_json(Json& _json, Compilation::Compiler const& _compiler)
{
	_json["name"] = _compiler.name;
	_json["version"] = _compiler.version;
}

void schema::materials::to_json(Json& _json, Compilation const& _compilation)
{
	_json["id"] = _compilation.id;
	_json["compiler"] = _compilation.compiler;
	if (_compilation.settings.has_value())
		_json["settings"] = *_compilation.settings;
	_json["sources"] = _compilation.sources;
}

void schema::to_json(Json& _json, Type::Reference const& _reference)
{
	_json = Json::object();
	_json["id"] = _reference.id;
}

void schema::to_json(Json& _json, Type::Specifier const& _specifier)
{
	std::visit(GenericVisitor{
		[&](Type::Reference const& _reference) { _json = _reference; },
		[&](std::unique_ptr<Type const> const& _type) { _json = *_type; },
	}, _specifier.value);
}

void schema::to_json(Json& _json, Type::Wrapper const& _wrapper)
{
	_json = Json::object();
	if (_wrapper.name.has_value())
		_json["name"] = *_wrapper.name;
	_json["type"] = _wrapper.type;
}

void schema::to_json(Json& _json, Type::Definition const& _definition)
{
	_json = Json::object();
	if (_definition.name.has_value())
		_json["name"] = *_definition.name;
	if (_definition.location.has_value())
		_json["location"] = *_definition.location;
}

void schema::to_json(Json& _json, Type const& _type)
{
	_json = Json::object();
	std::visit(GenericVisitor{
		[&](Type::UInt const& _uint)
		{
			_json["kind"] = "uint";
			_json["bits"] = _uint.bits;
		},
		[&](Type::Int const& _int)
		{
			_json["kind"] = "int";
			_json["bits"] = _int.bits;
		},
		[&](Type::Bool const&) { _json["kind"] = "bool"; },
		[&](Type::Bytes const& _bytes)
		{
			_json["kind"] = "bytes";
			if (_bytes.size.has_value())
				_json["size"] = *_bytes.size;
		},
		[&](Type::String const& _string)
		{
			_json["kind"] = "string";
			if (_string.encoding.has_value())
				_json["encoding"] = *_string.encoding;
		},
		[&](Type::UFixed const& _ufixed)
		{
			_json["kind"] = "ufixed";
			_json["bits"] = _ufixed.bits;
			_json["places"] = _ufixed.places;
		},
		[&](Type::Fixed const& _fixed)
		{
			_json["kind"] = "fixed";
			_json["bits"] = _fixed.bits;
			_json["places"] = _fixed.places;
		},
		[&](Type::Address const& _address)
		{
			_json["kind"] = "address";
			if (_address.payable.has_value())
				_json["payable"] = *_address.payable;
		},
		[&](Type::Contract const& _contract)
		{
			_json["kind"] = "contract";
			if (_contract.payable.has_value())
				_json["payable"] = *_contract.payable;
			if (_contract.kind == Type::Contract::Kind::Library)
				_json["library"] = true;
			else if (_contract.kind == Type::Contract::Kind::Interface)
				_json["interface"] = true;
			if (_contract.definition.has_value())
				_json["definition"] = *_contract.definition;
		},
		[&](Type::Enum const& _enum)
		{
			_json["kind"] = "enum";
			_json["values"] = _enum.values;
			if (_enum.definition.has_value())
				_json["definition"] = *_enum.definition;
		},
		[&](Type::Alias const& _alias)
		{
			_json["kind"] = "alias";
			_json["contains"] = _alias.contains;
			if (_alias.definition.has_value())
				_json["definition"] = *_alias.definition;
		},
		[&](Type::Array const& _array)
		{
			_json["kind"] = "array";
			_json["contains"] = _array.contains;
			if (_array.count.has_value())
				_json["count"] = *_array.count;
		},
		[&](Type::Mapping const& _mapping)
		{
			_json["kind"] = "mapping";
			_json["contains"] = Json{{"key", _mapping.key}, {"value", _mapping.value}};
		},
		[&](Type::Struct const& _struct)
		{
			_json["kind"] = "struct";
			_json["contains"] = _struct.contains;
			if (_struct.definition.has_value())
				_json["definition"] = *_struct.definition;
		},
		[&](Type::Tuple const& _tuple)
		{
			_json["kind"] = "tuple";
			_json["contains"] = _tuple.contains;
		},
		[&](Type::Function const& _function)
		{
			_json["kind"] = "function";
			_json[Type::Function::visibilityNames.at(_function.visibility)] = true;
			Json contains{{"parameters", _function.parameters}};
			if (_function.returns.has_value())
				contains["returns"] = *_function.returns;
			_json["contains"] = std::move(contains);
			if (_function.definition.has_value())
				_json["definition"] = *_function.definition;
		},
	}, _type.value);
}

void schema::to_json(Json& _json, Pointer::Expression const& _expression)
{
	std::visit(GenericVisitor{
		[&](Pointer::Literal const& _literal) { _json = _literal.value; },
		[&](Pointer::Variable const& _variable) { _json = _variable.identifier; },
		[&](Pointer::Constant const _constant) { _json = Pointer::constantNames.at(_constant); },
		[&](Pointer::Lookup const& _lookup)
		{
			_json = Json{{Pointer::Lookup::propertyNames.at(_lookup.property), _lookup.region}};
		},
		[&](Pointer::Read const& _read) { _json = Json{{"~read", _read.region}}; },
		[&](Pointer::Arithmetic const& _arithmetic)
		{
			_json = Json{{Pointer::Arithmetic::operatorNames.at(_arithmetic.op), _arithmetic.operands}};
		},
		[&](Pointer::Keccak256 const& _keccak256) { _json = Json{{"~keccak256", _keccak256.operands}}; },
		[&](Pointer::Concat const& _concat) { _json = Json{{"~concat", _concat.operands}}; },
		[&](Pointer::Resize const& _resize)
		{
			if (_resize.size.has_value())
				_json = Json{{"~sized" + std::to_string(*_resize.size), *_resize.operand}};
			else
				_json = Json{{"~wordsized", *_resize.operand}};
		},
	}, _expression.value);
}

void schema::to_json(Json& _json, Pointer::Region const& _region)
{
	_json = Json::object();
	if (_region.name.has_value())
		_json["name"] = *_region.name;
	_json["location"] = Pointer::locationNames.at(_region.location);
	if (_region.slot.has_value())
		_json["slot"] = *_region.slot;
	if (_region.offset.has_value())
		_json["offset"] = *_region.offset;
	if (_region.length.has_value())
		_json["length"] = *_region.length;
}

void schema::to_json(Json& _json, Pointer const& _pointer)
{
	std::visit(GenericVisitor{
		[&](Pointer::Region const& _region) { _json = _region; },
		[&](Pointer::Group const& _group) { _json = Json{{"group", _group.members}}; },
		[&](Pointer::List const& _list)
		{
			_json = Json{
				{
					"list",
					Json{
						{"count", _list.count},
						{"each", _list.each},
						{"is", *_list.is},
					},
				},
			};
		},
		[&](Pointer::Conditional const& _conditional)
		{
			_json = Json{{"if", _conditional.condition}, {"then", *_conditional.then}};
			if (_conditional.otherwise)
				_json["else"] = *_conditional.otherwise;
		},
		[&](Pointer::Scope const& _scope)
		{
			// Definitions are ordered while JSON object members are not, so each
			// definition becomes its own define/in level.
			Json inner = *_scope.in;
			for (auto definition = _scope.definitions.rbegin(); definition != _scope.definitions.rend(); ++definition)
				inner = Json{{"define", Json{{definition->first, definition->second}}}, {"in", std::move(inner)}};
			_json = std::move(inner);
		},
		[&](Pointer::TemplateReference const& _reference)
		{
			_json = Json{{"template", _reference.name}};
			if (!_reference.yields.empty())
			{
				Json yields = Json::object();
				for (auto const& [producedName, newName]: _reference.yields)
					yields[producedName] = newName;
				_json["yields"] = std::move(yields);
			}
		},
		[&](Pointer::Templates const& _templates)
		{
			Json templates = Json::object();
			for (auto const& [templateName, definition]: _templates.templates)
				templates[templateName] = definition;
			_json = Json{{"templates", std::move(templates)}, {"in", *_templates.in}};
		},
	}, _pointer.value);
}

void schema::to_json(Json& _json, Pointer::Template const& _template)
{
	_json = Json{{"expect", _template.expect}, {"for", *_template.body}};
}

void schema::to_json(Json& _json, Program::Contract const& _contract)
{
	if (_contract.name.has_value())
		_json["name"] = *_contract.name;
	_json["definition"] = _contract.definition;
}

void schema::program::to_json(Json& _json, Context::Variable const& _contextVariable)
{
	auto const numProperties =
		_contextVariable.identifier.has_value() +
		_contextVariable.declaration.has_value();
	solRequire(numProperties >= 1, EthdebugException, "Context variable has no properties.");
	if (_contextVariable.identifier.has_value())
	{
		solRequire(!_contextVariable.identifier->empty(), EthdebugException, "Variable identifier must not be empty.");
		_json["identifier"] = *_contextVariable.identifier;
	}
	if (_contextVariable.declaration.has_value())
		_json["declaration"] = *_contextVariable.declaration;
}

void schema::program::to_json(Json& _json, Context const& _context)
{
	solRequire(_context.code.has_value() + _context.remark.has_value() + _context.variables.has_value() >= 1, EthdebugException, "Context needs >=1 properties.");
	if (_context.code.has_value())
		_json["code"] = *_context.code;
	if (_context.variables.has_value())
	{
		solRequire(!_context.variables->empty(), EthdebugException, "Context variables must not be empty if provided.");
		_json["variables"] = *_context.variables;
	}
	if (_context.remark.has_value())
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
	if (_instruction.operation.has_value())
		_json["operation"] = *_instruction.operation;
	if (_instruction.context.has_value())
		_json["context"] = *_instruction.context;
}

void schema::to_json(Json& _json, Program const& _program)
{
	if (_program.ethdebug.has_value())
		_json["ethdebug"] = *_program.ethdebug;
	if (_program.compilation.has_value())
		_json["compilation"] = *_program.compilation;
	_json["contract"] = _program.contract;
	_json["environment"] = _program.environment;
	if (_program.context.has_value())
		_json["context"] = *_program.context;
	_json["instructions"] = _program.instructions;
}

void schema::to_json(Json& _json, Program::Environment const& _environment)
{
	_json = Program::environmentNames.at(_environment);
}

void schema::info::to_json(Json& _json, Resources const& _resources)
{
	if (_resources.ethdebug.has_value())
		_json["ethdebug"] = *_resources.ethdebug;
	_json["compilation"] = _resources.compilation;
	_json["types"] = Json::object();
	for (auto const& [id, typeDocument]: _resources.types)
		_json["types"][id] = typeDocument;
	_json["pointers"] = Json::object();
	for (auto const& [name, pointerTemplate]: _resources.pointers)
	{
		solAssert(Pointer::isIdentifier(name), "Pointer template name \"" + name + "\" is not an identifier.");
		_json["pointers"][name] = pointerTemplate;
	}
}

// ---------------------------------------------------------------------------
// Reading

namespace
{

/// @returns the enum value whose name in @a _names is @a _name, if any.
template<typename Enum>
std::optional<Enum> valueOfName(std::map<Enum, std::string> const& _names, std::string_view _name)
{
	for (auto const& [value, name]: _names)
		if (name == _name)
			return value;
	return std::nullopt;
}

std::string member(std::string_view _path, std::string_view _name)
{
	return std::string(_path) + "." + std::string(_name);
}

std::string element(std::string_view _path, size_t _index)
{
	return std::string(_path) + "[" + std::to_string(_index) + "]";
}

/// Type documents, pointers and expressions nest recursively.
/// Input deeper than this is rejected rather than parsed with unbounded recursion.
constexpr size_t maximumNestingDepth = 256;

void requireDepth(size_t _depth, std::string_view _path)
{
	if (_depth >= maximumNestingDepth)
		solThrow(JsonValidationError, std::string(_path) + " is nested too deeply.");
}

std::string identifierFromJson(Json const& _json, std::string_view _path)
{
	std::string identifier = valueOfType<std::string>(_json, _path);
	if (!schema::Pointer::isIdentifier(identifier))
		solThrow(JsonValidationError, std::string(_path) + " must be an identifier.");
	return identifier;
}

void requireIdentifierKey(std::string const& _key, std::string_view _path)
{
	if (!schema::Pointer::isIdentifier(_key))
		solThrow(JsonValidationError, std::string(_path) + " has the member \"" + _key + "\", which is not an identifier.");
}

/// A `0x`-prefixed string of at least one hex digit.
bool isHexString(std::string_view _text)
{
	if (_text.size() < 3 || _text.substr(0, 2) != "0x")
		return false;
	for (char const c: _text.substr(2))
		if (!std::isxdigit(static_cast<unsigned char>(c)))
			return false;
	return true;
}

/// A decimal number without leading zeros.
bool isCanonicalDecimal(std::string_view _text)
{
	if (_text.empty() || (_text.size() > 1 && _text.front() == '0'))
		return false;
	for (char const c: _text)
		if (!std::isdigit(static_cast<unsigned char>(c)))
			return false;
	return true;
}

schema::Type::Definition definitionFromJson(Json const& _json, std::string_view _path)
{
	requireOnlyMembers(_json, {"name", "location"}, _path);
	std::optional<std::string> name = optionalValue<std::string>(_json, "name", _path);
	std::optional<schema::materials::SourceRange> location;
	if (Json const* locationJson = optionalMember(_json, "location", _path);
		locationJson != nullptr
	)
		location = schema::materials::sourceRangeFromJson(*locationJson, member(_path, "location"));
	if (!name.has_value() && !location.has_value())
		solThrow(JsonValidationError, std::string(_path) + " must have a name or a location.");
	if (name.has_value() && name->empty())
		solThrow(JsonValidationError, member(_path, "name") + " must not be empty.");
	return schema::Type::Definition{std::move(name), std::move(location)};
}

std::optional<schema::Type::Definition> optionalDefinition(Json const& _json, std::string_view _path)
{
	if (Json const* definition = optionalMember(_json, "definition", _path);
		definition != nullptr
	)
		return definitionFromJson(*definition, member(_path, "definition"));
	return std::nullopt;
}

std::optional<schema::data::Unsigned> optionalUnsignedFromJson(Json const& _json, std::string_view _name, std::string_view _path)
{
	if (Json const* value = optionalMember(_json, _name, _path);
		value != nullptr
	)
		return schema::data::unsignedFromJson(*value, member(_path, _name));
	return std::nullopt;
}

unsigned bitsFromJson(Json const& _json, std::string_view _path)
{
	unsigned const bits = requiredValue<unsigned>(_json, "bits", _path);
	if (bits < 8 || bits > 256 || bits % 8 != 0)
		solThrow(JsonValidationError, member(_path, "bits") + " must be a multiple of 8 between 8 and 256.");
	return bits;
}

unsigned placesFromJson(Json const& _json, std::string_view _path)
{
	unsigned const places = requiredValue<unsigned>(_json, "places", _path);
	if (places < 1 || places > 80)
		solThrow(JsonValidationError, member(_path, "places") + " must be between 1 and 80.");
	return places;
}

schema::Type typeFromJson(Json const& _json, std::string_view _path, size_t _depth);
schema::Type::Wrapper wrapperFromJson(Json const& _json, std::string_view _path, size_t _depth);

std::vector<schema::Type::Wrapper> wrappersFromJson(Json const& _json, std::string_view _path, size_t _depth)
{
	requireArray(_json, _path);
	std::vector<schema::Type::Wrapper> wrappers;
	for (size_t index = 0; index < _json.size(); ++index)
		wrappers.emplace_back(wrapperFromJson(_json.at(index), element(_path, index), _depth));
	return wrappers;
}

schema::Type::Specifier specifierFromJson(Json const& _json, std::string_view _path, size_t _depth)
{
	requireObject(_json, _path);
	// A specifier with an `id` is a reference; anything else must be a type.
	if (_json.contains("id"))
	{
		requireOnlyMembers(_json, {"id"}, _path);
		return schema::Type::Specifier{schema::Type::Reference{schema::materials::idFromJson(_json.at("id"), member(_path, "id"))}};
	}
	return schema::Type::Specifier{std::make_unique<schema::Type const>(typeFromJson(_json, _path, _depth + 1))};
}

schema::Type::Wrapper wrapperFromJson(Json const& _json, std::string_view _path, size_t _depth)
{
	requireDepth(_depth, _path);
	requireOnlyMembers(_json, {"name", "type"}, _path);
	return schema::Type::Wrapper{
		optionalValue<std::string>(_json, "name", _path),
		specifierFromJson(requiredMember(_json, "type", _path), member(_path, "type"), _depth),
	};
}

schema::Type typeFromJson(Json const& _json, std::string_view _path, size_t _depth)
{
	using Type = schema::Type;
	requireDepth(_depth, _path);
	requireObject(_json, _path);
	std::string const kind = requiredValue<std::string>(_json, "kind", _path);
	auto const requireClass = [&](std::string_view _class) {
		if (std::optional<std::string> declared = optionalValue<std::string>(_json, "class", _path);
			declared.has_value()
		)
			if (*declared != _class)
				solThrow(JsonValidationError, member(_path, "class") + " must be \"" + std::string(_class) + "\" for kind \"" + kind + "\".");
	};
	auto const validateElementaryType = [&](std::set<std::string_view> _members) {
		_members.insert("class");
		_members.insert("kind");
		requireOnlyMembers(_json, _members, _path);
		requireClass("elementary");
	};
	auto const validateComplexType = [&](std::set<std::string_view> _members) {
		_members.insert("class");
		_members.insert("kind");
		_members.insert("contains");
		requireOnlyMembers(_json, _members, _path);
		requireClass("complex");
	};
	auto const contains = [&]() -> Json const& { return requiredMember(_json, "contains", _path); };
	std::string const containsPath = member(_path, "contains");

	if (kind == "uint")
	{
		validateElementaryType({"bits"});
		return Type{Type::UInt{bitsFromJson(_json, _path)}};
	}
	if (kind == "int")
	{
		validateElementaryType({"bits"});
		return Type{Type::Int{bitsFromJson(_json, _path)}};
	}
	if (kind == "bool")
	{
		validateElementaryType({});
		return Type{Type::Bool{}};
	}
	if (kind == "bytes")
	{
		validateElementaryType({"size"});
		return Type{Type::Bytes{optionalUnsignedFromJson(_json, "size", _path)}};
	}
	if (kind == "string")
	{
		validateElementaryType({"encoding"});
		return Type{Type::String{optionalValue<std::string>(_json, "encoding", _path)}};
	}
	if (kind == "ufixed")
	{
		validateElementaryType({"bits", "places"});
		return Type{Type::UFixed{bitsFromJson(_json, _path), placesFromJson(_json, _path)}};
	}
	if (kind == "fixed")
	{
		validateElementaryType({"bits", "places"});
		return Type{Type::Fixed{bitsFromJson(_json, _path), placesFromJson(_json, _path)}};
	}
	if (kind == "address")
	{
		validateElementaryType({"payable"});
		return Type{Type::Address{optionalValue<bool>(_json, "payable", _path)}};
	}
	if (kind == "contract")
	{
		validateElementaryType({"payable", "library", "interface", "definition"});
		Type::Contract contract;
		contract.payable = optionalValue<bool>(_json, "payable", _path);
		bool const library = optionalValue<bool>(_json, "library", _path).value_or(false);
		bool const interface = optionalValue<bool>(_json, "interface", _path).value_or(false);
		if (library && interface)
			solThrow(JsonValidationError, std::string(_path) + " cannot be both a library and an interface.");
		contract.kind = library ? Type::Contract::Kind::Library : interface ? Type::Contract::Kind::Interface : Type::Contract::Kind::Contract;
		contract.definition = optionalDefinition(_json, _path);
		return Type{std::move(contract)};
	}
	if (kind == "enum")
	{
		validateElementaryType({"values", "definition"});
		Type::Enum document;
		Json const& values = requireArray(requiredMember(_json, "values", _path), member(_path, "values"));
		for (size_t index = 0; index < values.size(); ++index)
			document.values.emplace_back(valueOfType<std::string>(values.at(index), element(member(_path, "values"), index)));
		document.definition = optionalDefinition(_json, _path);
		return Type{std::move(document)};
	}
	if (kind == "alias")
	{
		validateComplexType({"definition"});
		return Type{Type::Alias{wrapperFromJson(contains(), containsPath, _depth + 1), optionalDefinition(_json, _path)}};
	}
	if (kind == "array")
	{
		validateComplexType({"count"});
		return Type{Type::Array{
			wrapperFromJson(contains(), containsPath, _depth + 1),
			optionalUnsignedFromJson(_json, "count", _path),
		}};
	}
	if (kind == "mapping")
	{
		validateComplexType({});
		Json const& components = contains();
		requireOnlyMembers(components, {"key", "value"}, containsPath);
		return Type{Type::Mapping{
			wrapperFromJson(requiredMember(components, "key", containsPath), member(containsPath, "key"), _depth + 1),
			wrapperFromJson(requiredMember(components, "value", containsPath), member(containsPath, "value"), _depth + 1),
		}};
	}
	if (kind == "struct")
	{
		validateComplexType({"definition"});
		return Type{Type::Struct{wrappersFromJson(contains(), containsPath, _depth + 1), optionalDefinition(_json, _path)}};
	}
	if (kind == "tuple")
	{
		validateComplexType({});
		return Type{Type::Tuple{wrappersFromJson(contains(), containsPath, _depth + 1)}};
	}
	if (kind == "function")
	{
		validateComplexType({"internal", "external", "definition"});
		bool const internal = optionalValue<bool>(_json, "internal", _path).value_or(false);
		bool const external = optionalValue<bool>(_json, "external", _path).value_or(false);
		if (internal == external)
			solThrow(JsonValidationError, std::string(_path) + " must be either internal or external.");
		Json const& components = contains();
		requireOnlyMembers(components, {"parameters", "returns"}, containsPath);
		Type::Function function{
			internal ? Type::Function::Visibility::Internal : Type::Function::Visibility::External,
			wrapperFromJson(requiredMember(components, "parameters", containsPath), member(containsPath, "parameters"), _depth + 1),
			std::nullopt,
			optionalDefinition(_json, _path),
		};
		if (Json const* returns = optionalMember(components, "returns", containsPath);
			returns != nullptr
		)
			function.returns = wrapperFromJson(*returns, member(containsPath, "returns"), _depth + 1);
		return Type{std::move(function)};
	}
	solThrow(JsonValidationError, member(_path, "kind") + " has the unknown value \"" + kind + "\".");
}

schema::Pointer::Expression expressionFromJson(Json const& _json, std::string_view _path, size_t _depth);
schema::Pointer pointerFromJson(Json const& _json, std::string_view _path, size_t _depth);
schema::Pointer::Template templateFromJson(Json const& _json, std::string_view _path, size_t _depth);

std::string regionReferenceFromJson(Json const& _json, std::string_view _path)
{
	std::string reference = valueOfType<std::string>(_json, _path);
	if (reference != "~this" && !schema::Pointer::isIdentifier(reference))
		solThrow(JsonValidationError, std::string(_path) + " must name a region.");
	return reference;
}

schema::Pointer::Operands operandsFromJson(Json const& _json, std::string_view _path, size_t _depth, std::optional<size_t> _arity)
{
	requireArray(_json, _path);
	if (_arity.has_value() && _json.size() != *_arity)
		solThrow(JsonValidationError, std::string(_path) + " must have exactly " + std::to_string(*_arity) + " operands.");
	schema::Pointer::Operands operands;
	for (size_t index = 0; index < _json.size(); ++index)
		operands.emplace_back(expressionFromJson(_json.at(index), element(_path, index), _depth + 1));
	return operands;
}

schema::Pointer::Expression expressionFromJson(Json const& _json, std::string_view _path, size_t _depth)
{
	using Pointer = schema::Pointer;
	requireDepth(_depth, _path);

	if (_json.is_number_integer() || _json.is_string())
	{
		if (_json.is_string())
			if (std::optional<Pointer::Constant> constant = valueOfName(Pointer::constantNames, _json.get<std::string>());
				constant.has_value()
			)
				return Pointer::Expression{*constant};
		if (_json.is_string() && schema::Pointer::isIdentifier(_json.get<std::string>()))
			return Pointer::Expression{Pointer::Variable{_json.get<std::string>()}};
		return Pointer::Expression{Pointer::Literal{schema::data::unsignedFromJson(_json, _path)}};
	}

	requireObject(_json, _path);
	if (_json.size() != 1)
		solThrow(JsonValidationError, std::string(_path) + " must have exactly one member.");
	std::string const key = _json.begin().key();
	Json const& value = _json.begin().value();
	std::string const valuePath = member(_path, key);

	if (std::optional<Pointer::Lookup::Property> property = valueOfName(Pointer::Lookup::propertyNames, key);
		property.has_value()
	)
		return Pointer::Expression{Pointer::Lookup{*property, regionReferenceFromJson(value, valuePath)}};
	if (key == "~read")
		return Pointer::Expression{Pointer::Read{regionReferenceFromJson(value, valuePath)}};
	if (std::optional<Pointer::Arithmetic::Operator> op = valueOfName(Pointer::Arithmetic::operatorNames, key);
		op.has_value()
	)
	{
		using Operator = Pointer::Arithmetic::Operator;
		bool const binary = *op == Operator::Difference || *op == Operator::Quotient || *op == Operator::Remainder;
		std::optional<size_t> const arity = binary ? std::optional<size_t>{2} : std::nullopt;
		return Pointer::Expression{Pointer::Arithmetic{*op, operandsFromJson(value, valuePath, _depth, arity)}};
	}
	if (key == "~keccak256")
		return Pointer::Expression{Pointer::Keccak256{operandsFromJson(value, valuePath, _depth, std::nullopt)}};
	if (key == "~concat")
		return Pointer::Expression{Pointer::Concat{operandsFromJson(value, valuePath, _depth, std::nullopt)}};
	if (key == "~wordsized")
		return Pointer::Expression{Pointer::Resize{std::nullopt, std::make_unique<Pointer::Expression const>(expressionFromJson(value, valuePath, _depth + 1))}};
	if (key.starts_with("~sized"))
	{
		std::string const width = key.substr(6);
		if (!isCanonicalDecimal(width) || width == "0")
			solThrow(JsonValidationError, std::string(_path) + " has the malformed resize key \"" + key + "\".");
		std::uint64_t size = 0;
		try
		{
			size = std::stoull(width);
		}
		catch (std::out_of_range const&)
		{
			solThrow(JsonValidationError, std::string(_path) + " has the malformed resize key \"" + key + "\".");
		}
		return Pointer::Expression{Pointer::Resize{size, std::make_unique<Pointer::Expression const>(expressionFromJson(value, valuePath, _depth + 1))}};
	}
	solThrow(JsonValidationError, std::string(_path) + " has the unknown expression key \"" + key + "\".");
}

std::optional<schema::Pointer::Expression> optionalExpression(Json const& _json, std::string_view _name, std::string_view _path, size_t _depth)
{
	if (Json const* value = optionalMember(_json, _name, _path);
		value != nullptr
	)
		return expressionFromJson(*value, member(_path, _name), _depth + 1);
	return std::nullopt;
}

schema::Pointer::Region regionFromJson(Json const& _json, std::string_view _path, size_t _depth)
{
	using Location = schema::Pointer::Location;
	requireOnlyMembers(_json, {"name", "location", "slot", "offset", "length"}, _path);
	std::optional<std::string> name;
	if (Json const* nameJson = optionalMember(_json, "name", _path);
		nameJson != nullptr
	)
		name = identifierFromJson(*nameJson, member(_path, "name"));
	std::string const locationName = requiredValue<std::string>(_json, "location", _path);
	std::optional<Location> const location = valueOfName(schema::Pointer::locationNames, locationName);
	if (!location.has_value())
		solThrow(JsonValidationError, member(_path, "location") + " has the unknown value \"" + locationName + "\".");
	bool const wordOriented = *location == Location::Stack || *location == Location::Storage || *location == Location::Transient;
	std::optional<schema::Pointer::Expression> slot = optionalExpression(_json, "slot", _path, _depth);
	std::optional<schema::Pointer::Expression> offset = optionalExpression(_json, "offset", _path, _depth);
	std::optional<schema::Pointer::Expression> length = optionalExpression(_json, "length", _path, _depth);
	// Word-oriented locations address by slot, byte-oriented ones by offset and length.
	if (wordOriented && !slot.has_value())
		solThrow(JsonValidationError, std::string(_path) + " must address its slot.");
	if (!wordOriented && (slot.has_value() || !offset.has_value() || !length.has_value()))
		solThrow(JsonValidationError, std::string(_path) + " must address its offset and length, and has no slot.");
	return schema::Pointer::Region{std::move(name), *location, std::move(slot), std::move(offset), std::move(length)};
}

schema::Pointer pointerFromJson(Json const& _json, std::string_view _path, size_t _depth)
{
	using Pointer = schema::Pointer;
	requireDepth(_depth, _path);
	requireObject(_json, _path);
	auto const subPointer = [&](Json const& _sub, std::string const& _subPath) {
		return std::make_unique<Pointer const>(pointerFromJson(_sub, _subPath, _depth + 1));
	};

	if (_json.contains("location"))
		return Pointer{regionFromJson(_json, _path, _depth)};
	if (_json.contains("group"))
	{
		requireOnlyMembers(_json, {"group"}, _path);
		Json const& members = requireArray(_json.at("group"), member(_path, "group"));
		if (members.empty())
			solThrow(JsonValidationError, member(_path, "group") + " must have at least one member.");
		std::vector<Pointer> groupMembers;
		for (size_t index = 0; index < members.size(); ++index)
			groupMembers.emplace_back(pointerFromJson(members.at(index), element(member(_path, "group"), index), _depth + 1));
		return Pointer{Pointer::Group{std::move(groupMembers)}};
	}
	if (_json.contains("list"))
	{
		requireOnlyMembers(_json, {"list"}, _path);
		std::string const listPath = member(_path, "list");
		Json const& list = _json.at("list");
		requireOnlyMembers(list, {"count", "each", "is"}, listPath);
		return Pointer{Pointer::List{
			expressionFromJson(requiredMember(list, "count", listPath), member(listPath, "count"), _depth + 1),
			identifierFromJson(requiredMember(list, "each", listPath), member(listPath, "each")),
			subPointer(requiredMember(list, "is", listPath), member(listPath, "is")),
		}};
	}
	if (_json.contains("if"))
	{
		requireOnlyMembers(_json, {"if", "then", "else"}, _path);
		Pointer::Conditional conditional{
			expressionFromJson(_json.at("if"), member(_path, "if"), _depth + 1),
			subPointer(requiredMember(_json, "then", _path), member(_path, "then")),
			nullptr,
		};
		if (Json const* otherwise = optionalMember(_json, "else", _path);
			otherwise != nullptr
		)
			conditional.otherwise = subPointer(*otherwise, member(_path, "else"));
		return Pointer{std::move(conditional)};
	}
	if (_json.contains("define"))
	{
		// A define/in chain is folded into one ordered definition list. The
		// members of one define object cannot reference each other, so their
		// order within that object does not matter.
		std::vector<std::pair<std::string, Pointer::Expression>> definitions;
		Json const* current = &_json;
		std::string path(_path);
		size_t depth = _depth;
		while (current->contains("define"))
		{
			requireDepth(depth, path);
			requireOnlyMembers(*current, {"define", "in"}, path);
			Json const& define = requireObject(current->at("define"), member(path, "define"));
			if (define.empty())
				solThrow(JsonValidationError, member(path, "define") + " must define at least one variable.");
			for (auto const& [name, value]: define.items())
			{
				requireIdentifierKey(name, member(path, "define"));
				definitions.emplace_back(name, expressionFromJson(value, member(member(path, "define"), name), depth + 1));
			}
			current = &requiredMember(*current, "in", path);
			path = member(path, "in");
			++depth;
		}
		return Pointer{Pointer::Scope{std::move(definitions), std::make_unique<Pointer const>(pointerFromJson(*current, path, depth))}};
	}
	if (_json.contains("template"))
	{
		requireOnlyMembers(_json, {"template", "yields"}, _path);
		std::string name = identifierFromJson(_json.at("template"), member(_path, "template"));
		std::vector<std::pair<std::string, std::string>> yields;
		if (Json const* yieldsJson = optionalMember(_json, "yields", _path);
			yieldsJson != nullptr
		)
		{
			requireObject(*yieldsJson, member(_path, "yields"));
			for (auto const& [producedName, newName]: yieldsJson->items())
			{
				requireIdentifierKey(producedName, member(_path, "yields"));
				yields.emplace_back(producedName, identifierFromJson(newName, member(member(_path, "yields"), producedName)));
			}
		}
		return Pointer{Pointer::TemplateReference{std::move(name), std::move(yields)}};
	}
	if (_json.contains("templates"))
	{
		requireOnlyMembers(_json, {"templates", "in"}, _path);
		std::vector<std::pair<std::string, Pointer::Template>> templates;
		Json const& definitions = requireObject(_json.at("templates"), member(_path, "templates"));
		for (auto const& [templateName, definition]: definitions.items())
		{
			requireIdentifierKey(templateName, member(_path, "templates"));
			templates.emplace_back(templateName, templateFromJson(definition, member(member(_path, "templates"), templateName), _depth + 1));
		}
		return Pointer{Pointer::Templates{std::move(templates), subPointer(requiredMember(_json, "in", _path), member(_path, "in"))}};
	}
	solThrow(JsonValidationError, std::string(_path) + " is not a pointer: expected one of location, group, list, if, define, template or templates.");
}

schema::Pointer::Template templateFromJson(Json const& _json, std::string_view _path, size_t _depth)
{
	requireDepth(_depth, _path);
	requireOnlyMembers(_json, {"expect", "for"}, _path);
	std::vector<std::string> expect;
	std::set<std::string> parameters;
	Json const& expectJson = requireArray(requiredMember(_json, "expect", _path), member(_path, "expect"));
	for (size_t index = 0; index < expectJson.size(); ++index)
	{
		std::string parameter = identifierFromJson(expectJson.at(index), element(member(_path, "expect"), index));
		if (!parameters.insert(parameter).second)
			solThrow(JsonValidationError, member(_path, "expect") + " has the duplicate parameter " + parameter + ".");
		expect.emplace_back(std::move(parameter));
	}
	return schema::Pointer::Template{
		std::move(expect),
		std::make_unique<schema::Pointer const>(pointerFromJson(requiredMember(_json, "for", _path), member(_path, "for"), _depth + 1)),
	};
}

}

schema::data::Unsigned schema::data::unsignedFromJson(Json const& _json, std::string_view _path)
{
	if (_json.is_number_unsigned())
		return Unsigned{_json.get<uint64_t>()};
	if (_json.is_string() && isHexString(_json.get<std::string>()))
		return Unsigned{HexValue{fromHex(_json.get<std::string>())}};
	solThrow(JsonValidationError, std::string(_path) + " must be an unsigned number or a 0x-prefixed hex string.");
}

schema::materials::ID schema::materials::idFromJson(Json const& _json, std::string_view _path)
{
	if (_json.is_string())
		return ID{_json.get<std::string>()};
	if (_json.is_number_unsigned())
		return ID{_json.get<uint64_t>()};
	solThrow(JsonValidationError, std::string(_path) + " must be a string or an unsigned number.");
}

schema::materials::SourceRange schema::materials::sourceRangeFromJson(Json const& _json, std::string_view _path)
{
	requireOnlyMembers(_json, {"source", "range"}, _path);
	SourceRange sourceRange;
	Json const& source = requiredMember(_json, "source", _path);
	std::string const sourcePath = member(_path, "source");
	requireOnlyMembers(source, {"id", "type"}, sourcePath);
	sourceRange.source.id = idFromJson(requiredMember(source, "id", sourcePath), member(sourcePath, "id"));
	if (std::optional<std::string> referenceType = optionalValue<std::string>(source, "type", sourcePath);
		referenceType.has_value()
	)
	{
		sourceRange.source.type = valueOfName(Reference::typeNames, *referenceType);
		if (!sourceRange.source.type.has_value())
			solThrow(JsonValidationError, member(sourcePath, "type") + " has the unknown value \"" + *referenceType + "\".");
	}
	if (Json const* range = optionalMember(_json, "range", _path);
		range != nullptr
	)
	{
		std::string const rangePath = member(_path, "range");
		requireOnlyMembers(*range, {"offset", "length"}, rangePath);
		sourceRange.range = SourceRange::Range{
			.length = data::unsignedFromJson(requiredMember(*range, "length", rangePath), member(rangePath, "length")),
			.offset = data::unsignedFromJson(requiredMember(*range, "offset", rangePath), member(rangePath, "offset")),
		};
	}
	return sourceRange;
}

schema::Type schema::typeFromJson(Json const& _json, std::string_view _path)
{
	return ::typeFromJson(_json, _path, 0);
}

schema::Type::Wrapper schema::wrapperFromJson(Json const& _json, std::string_view _path)
{
	return ::wrapperFromJson(_json, _path, 0);
}

schema::Pointer::Expression schema::expressionFromJson(Json const& _json, std::string_view _path)
{
	return ::expressionFromJson(_json, _path, 0);
}

schema::Pointer schema::pointerFromJson(Json const& _json, std::string_view _path)
{
	return ::pointerFromJson(_json, _path, 0);
}

schema::Pointer::Template schema::templateFromJson(Json const& _json, std::string_view _path)
{
	return ::templateFromJson(_json, _path, 0);
}

std::map<std::string, schema::Type> schema::info::typesFromJson(Json const& _json, std::string_view _path)
{
	requireObject(_json, _path);
	std::map<std::string, Type> types;
	for (auto const& [id, document]: _json.items())
		types.emplace(id, ::typeFromJson(document, member(_path, id), 0));
	return types;
}

std::map<std::string, schema::Pointer::Template> schema::info::pointersFromJson(Json const& _json, std::string_view _path)
{
	requireObject(_json, _path);
	std::map<std::string, Pointer::Template> pointers;
	for (auto const& [name, definition]: _json.items())
	{
		requireIdentifierKey(name, _path);
		pointers.emplace(name, ::templateFromJson(definition, member(_path, name), 0));
	}
	return pointers;
}
