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

#include <libsolidity/codegen/ir/SemanticDebugDataBuilder.h>

#include <libsolidity/ast/AST.h>
#include <libsolidity/ast/Types.h>
#include <libsolidity/codegen/ir/IRVariable.h>

#include <liblangutil/SemanticDebugData.h>

#include <libsolutil/Common.h>
#include <libsolutil/Numeric.h>

#include <memory>
#include <optional>
#include <set>
#include <string>
#include <utility>
#include <vector>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::langutil;

namespace
{

using PointerExpression = SemanticDebugPointerExpression;

/// Type documents under construction, together with the compilation's source
/// indices: declaration ranges are published with the same numeric source IDs
/// the ethdebug.compilation record uses, never with paths.
struct TypeRegistry
{
	std::map<std::string, Json> documents;
	std::map<std::string, unsigned> const* sourceIndices = nullptr;
};

std::optional<uint64_t> sourceID(TypeRegistry const& _types, SourceLocation const& _location)
{
	if (!_types.sourceIndices || !_location.sourceName)
		return std::nullopt;
	auto const it = _types.sourceIndices->find(*_location.sourceName);
	if (it == _types.sourceIndices->end())
		return std::nullopt;
	return it->second;
}

/// An ethdebug identifier must not start with `$`, which a Solidity identifier
/// may. Every name the producer publishes passes through here.
std::string identifier(std::string const& _name)
{
	solAssert(!_name.empty());
	return _name.front() == '$' ? "_" + _name : _name;
}

/// Registers the ethdebug/format/type document for @a _type - and every type
/// it composes - into @a _types under the compiler's type identifiers. There
/// is no intermediate representation: what this builds is what the sidecar
/// serializes and what ethdebug.resources.types publishes. Wrappers reference
/// composed types by `{"id": ...}`, and the placeholder inserted before
/// descending is what terminates recursive types.
/// @returns false for a type the schema has no document for, such as a
/// literal or a magic type; such a type composes into no document either.
bool registerTypeDocument(TypeRegistry& _types, Type const& _type);

std::optional<Json> typeWrapper(TypeRegistry& _types, std::optional<std::string> _name, Type const& _type)
{
	if (!registerTypeDocument(_types, _type))
		return std::nullopt;
	Json wrapper = Json::object();
	if (_name)
		wrapper["name"] = std::move(*_name);
	wrapper["type"] = Json{{"id", _type.identifier()}};
	return wrapper;
}

/// The wrappers of @a _types in order, or nothing if any of them has no document.
std::optional<Json> typeWrappers(TypeRegistry& _types, std::vector<Type const*> const& _componentTypes)
{
	Json wrappers = Json::array();
	for (Type const* componentType: _componentTypes)
	{
		if (!componentType)
			continue;
		std::optional<Json> wrapper = typeWrapper(_types, std::nullopt, *componentType);
		if (!wrapper)
			return std::nullopt;
		wrappers.emplace_back(std::move(*wrapper));
	}
	return wrappers;
}

Json typeDefinition(TypeRegistry const& _types, Declaration const& _declaration)
{
	Json definition = Json::object();
	if (!_declaration.name().empty())
		definition["name"] = _declaration.name();
	SourceLocation const& location = _declaration.location();
	if (std::optional<uint64_t> source = sourceID(_types, location); source && location.hasText())
		definition["location"] = Json{
			{"range", Json{{"length", location.end - location.start}, {"offset", location.start}}},
			{"source", Json{{"id", *source}}}
		};
	return definition;
}

std::optional<Json> typeDocument(TypeRegistry& _types, Type const& _type)
{
	Json result = Json::object();
	auto attachDefinition = [&](Declaration const& _declaration) {
		Json definition = typeDefinition(_types, _declaration);
		if (!definition.empty())
			result["definition"] = std::move(definition);
	};
	auto contains = [&](Type const& _componentType) -> bool {
		std::optional<Json> wrapper = typeWrapper(_types, std::nullopt, _componentType);
		if (wrapper)
			result["contains"] = std::move(*wrapper);
		return wrapper.has_value();
	};

	switch (_type.category())
	{
	case Type::Category::Address:
	{
		auto const& addressType = dynamic_cast<AddressType const&>(_type);
		result["kind"] = "address";
		result["payable"] = addressType.stateMutability() == StateMutability::Payable;
		break;
	}
	case Type::Category::Integer:
	{
		auto const& integerType = dynamic_cast<IntegerType const&>(_type);
		result["kind"] = integerType.isSigned() ? "int" : "uint";
		result["bits"] = integerType.numBits();
		break;
	}
	case Type::Category::FixedPoint:
	{
		auto const& fixedPointType = dynamic_cast<FixedPointType const&>(_type);
		result["kind"] = fixedPointType.isSigned() ? "fixed" : "ufixed";
		result["bits"] = fixedPointType.numBits();
		result["places"] = fixedPointType.fractionalDigits();
		break;
	}
	case Type::Category::Bool:
		result["kind"] = "bool";
		break;
	case Type::Category::FixedBytes:
	{
		auto const& bytesType = dynamic_cast<FixedBytesType const&>(_type);
		result["kind"] = "bytes";
		result["size"] = bytesType.numBytes();
		break;
	}
	case Type::Category::Array:
	{
		auto const& arrayType = dynamic_cast<ArrayType const&>(_type);
		if (arrayType.isByteArrayOrString())
		{
			result["kind"] = arrayType.isString() ? "string" : "bytes";
			break;
		}
		result["kind"] = "array";
		if (!arrayType.isDynamicallySized())
			result["count"] = toCompactHexWithPrefix(arrayType.length());
		if (!contains(*arrayType.baseType()))
			return std::nullopt;
		break;
	}
	case Type::Category::ArraySlice:
	{
		// A slice's representation is the dynamic array it views, and no
		// consumer distinguishes the two, so no separate kind is carried.
		auto const& sliceType = dynamic_cast<ArraySliceType const&>(_type);
		result["kind"] = "array";
		if (!contains(*sliceType.arrayType().baseType()))
			return std::nullopt;
		break;
	}
	case Type::Category::Contract:
	{
		auto const& contractType = dynamic_cast<ContractType const&>(_type);
		result["kind"] = "contract";
		result["payable"] = contractType.isPayable();
		if (contractType.contractDefinition().isLibrary())
			result["library"] = true;
		else if (contractType.contractDefinition().isInterface())
			result["interface"] = true;
		attachDefinition(contractType.contractDefinition());
		break;
	}
	case Type::Category::Struct:
	{
		auto const& structType = dynamic_cast<StructType const&>(_type);
		Json members = Json::array();
		for (ASTPointer<VariableDeclaration> const& member: structType.structDefinition().members())
		{
			if (!member->annotation().type)
				continue;
			std::optional<Json> wrapper = typeWrapper(_types, member->name(), *member->annotation().type);
			if (!wrapper)
				return std::nullopt;
			members.emplace_back(std::move(*wrapper));
		}
		result["kind"] = "struct";
		result["contains"] = std::move(members);
		attachDefinition(structType.structDefinition());
		break;
	}
	case Type::Category::Enum:
	{
		auto const& enumType = dynamic_cast<EnumType const&>(_type);
		Json values = Json::array();
		for (ASTPointer<EnumValue> const& member: enumType.enumDefinition().members())
			values.emplace_back(member->name());
		result["kind"] = "enum";
		result["values"] = std::move(values);
		attachDefinition(enumType.enumDefinition());
		break;
	}
	case Type::Category::UserDefinedValueType:
	{
		auto const& aliasType = dynamic_cast<UserDefinedValueType const&>(_type);
		result["kind"] = "alias";
		if (!contains(aliasType.underlyingType()))
			return std::nullopt;
		attachDefinition(aliasType.definition());
		break;
	}
	case Type::Category::Tuple:
	{
		auto const& tupleType = dynamic_cast<TupleType const&>(_type);
		std::optional<Json> members = typeWrappers(_types, tupleType.components());
		if (!members)
			return std::nullopt;
		result["kind"] = "tuple";
		result["contains"] = std::move(*members);
		break;
	}
	case Type::Category::Mapping:
	{
		auto const& mappingType = dynamic_cast<MappingType const&>(_type);
		std::optional<Json> key = typeWrapper(_types, std::nullopt, *mappingType.keyType());
		std::optional<Json> value = typeWrapper(_types, std::nullopt, *mappingType.valueType());
		if (!key || !value)
			return std::nullopt;
		result["kind"] = "mapping";
		result["contains"] = Json{{"key", std::move(*key)}, {"value", std::move(*value)}};
		break;
	}
	case Type::Category::Function:
	{
		auto const& functionType = dynamic_cast<FunctionType const&>(_type);
		result["kind"] = "function";
		if (functionType.kind() == FunctionType::Kind::Internal)
			result["internal"] = true;
		else if (functionType.kind() == FunctionType::Kind::External)
			result["external"] = true;

		auto wrappedTuple = [&](std::vector<Type const*> const& _memberTypes) -> std::optional<Json> {
			std::optional<Json> wrappers = typeWrappers(_types, _memberTypes);
			if (!wrappers)
				return std::nullopt;
			return Json{{"type", Json{{"kind", "tuple"}, {"contains", std::move(*wrappers)}}}};
		};
		std::optional<Json> parameters = wrappedTuple(functionType.parameterTypes());
		if (!parameters)
			return std::nullopt;
		Json contained{{"parameters", std::move(*parameters)}};
		if (!functionType.returnParameterTypes().empty())
		{
			std::optional<Json> returns = wrappedTuple(functionType.returnParameterTypes());
			if (!returns)
				return std::nullopt;
			contained["returns"] = std::move(*returns);
		}
		result["contains"] = std::move(contained);

		if (functionType.hasDeclaration())
			attachDefinition(functionType.declaration());
		break;
	}
	case Type::Category::RationalNumber:
	case Type::Category::StringLiteral:
	case Type::Category::TypeType:
	case Type::Category::Modifier:
	case Type::Category::Magic:
	case Type::Category::Module:
	case Type::Category::InaccessibleDynamic:
		// Compile-time-only types have no runtime representation to describe.
		return std::nullopt;
	}
	return result;
}

bool registerTypeDocument(TypeRegistry& _types, Type const& _type)
{
	std::string const id = _type.identifier();
	if (_types.documents.count(id))
		return true;
	// Present before descending, so a recursive type terminates.
	_types.documents.emplace(id, Json::object());
	if (std::optional<Json> document = typeDocument(_types, _type))
	{
		_types.documents[id] = std::move(*document);
		return true;
	}
	_types.documents.erase(id);
	return false;
}

/// The region of one stack slot. A Yul name stands in for a stack depth that
/// is only known after the Yul-to-EVM transform; it is not a variable a
/// consumer can bind, so it is kept as its own expression kind and never
/// published as though it were a slot.
SemanticDebugPointer stackRegionPointer(std::string _name, std::string const& _yulVariable)
{
	return SemanticDebugPointer::region(
		SemanticDebugPointer::Location::Stack,
		std::move(_name),
		PointerExpression::yulLocal(_yulVariable)
	);
}

std::optional<std::string> sourceIdentifier(VariableDeclaration const& _variable)
{
	return _variable.name().empty() ? std::nullopt : std::make_optional(identifier(_variable.name()));
}

PointerExpression literalExpression(u256 const& _value)
{
	return PointerExpression::literal(toCompactHexWithPrefix(_value));
}

/// @returns @a _base advanced by @a _slots storage slots, folding the addition
/// into the literal when possible to keep emitted pointers readable.
PointerExpression advanceSlots(PointerExpression _base, u256 const& _slots)
{
	if (_slots == 0)
		return _base;
	if (_base.kind == PointerExpression::Kind::Literal && _base.value)
		return literalExpression(u256(*_base.value) + _slots);
	return PointerExpression::sum({std::move(_base), literalExpression(_slots)});
}

/// The name the state variable's pointer template is published under: the
/// location and the AST IDs of the most derived contract and the variable, so
/// that an inherited variable at a different slot in another contract of the
/// same compilation does not clash.
std::string stateVariablePointerTemplateName(
	ContractDefinition const& _contract,
	VariableDeclaration const& _variable,
	SemanticDebugPointer::Location _location
)
{
	solAssert(
		_location == SemanticDebugPointer::Location::Storage ||
		_location == SemanticDebugPointer::Location::Transient
	);
	std::string const prefix = _location == SemanticDebugPointer::Location::Storage ? "storage_" : "transient_";
	return prefix + std::to_string(_contract.id()) + "_" + std::to_string(_variable.id());
}

std::optional<SemanticDebugPointer> stackPointer(VariableDeclaration const& _variable)
{
	if (!_variable.annotation().type)
		return std::nullopt;

	std::vector<std::string> stackSlots = IRVariable(_variable).stackSlots();
	if (stackSlots.empty())
		return std::nullopt;

	if (stackSlots.size() == 1)
		return SemanticDebugPointer::region(
			SemanticDebugPointer::Location::Stack,
			sourceIdentifier(_variable),
			PointerExpression::yulLocal(stackSlots.front())
		);

	SemanticDebugPointer result;
	result.pointerClass = SemanticDebugPointer::Class::Group;
	result.name = sourceIdentifier(_variable);
	for (std::string const& stackSlot: stackSlots)
		result.group.emplace_back(stackRegionPointer(stackSlot, stackSlot));
	return result;
}

/// Builds the pointer of a state variable in storage or transient storage. One
/// builder instance describes one root pointer; mapping keys encountered
/// anywhere in it become template parameters collected in @a expectedParameters.
class StateVariablePointerBuilder
{
public:
	explicit StateVariablePointerBuilder(SemanticDebugPointer::Location _location):
		m_location(_location)
	{}

	SemanticDebugPointer build(
		Type const& _type,
		PointerExpression _slot,
		std::optional<PointerExpression> _offset,
		std::string const& _name
	)
	{
		if (auto const* mappingType = dynamic_cast<MappingType const*>(&_type))
			return buildMapping(*mappingType, std::move(_slot), _name);

		if (auto const* arrayType = dynamic_cast<ArrayType const*>(&_type))
		{
			if (arrayType->isByteArrayOrString())
				return buildBytesOrString(std::move(_slot), _name);
			if (arrayType->isDynamicallySized())
				return buildDynamicArray(*arrayType, std::move(_slot), _name);
			return buildStaticArray(*arrayType, std::move(_slot), _name);
		}

		if (auto const* structType = dynamic_cast<StructType const*>(&_type))
			return buildStruct(*structType, std::move(_slot), _name);

		return wholeRegion(_type, std::move(_slot), std::move(_offset), _name);
	}

	std::vector<std::string> takeExpectedParameters()
	{
		return std::move(m_expectedParameters);
	}

private:
	/// A single region covering the value as laid out from its base slot. Used
	/// for value types and as the fallback for compositions that are not (or
	/// cannot be) decomposed further.
	SemanticDebugPointer wholeRegion(
		Type const& _type,
		PointerExpression _slot,
		std::optional<PointerExpression> _offset,
		std::string const& _name
	)
	{
		u256 const byteLength = u256(_type.storageBytes()) * _type.storageSize();
		std::optional<PointerExpression> length;
		if (_offset.has_value() || byteLength != 32)
			length = literalExpression(byteLength);
		return SemanticDebugPointer::region(
			m_location,
			_name,
			std::move(_slot),
			std::move(_offset),
			std::move(length)
		);
	}

	/// The mapping value lives at `keccak256(pad(key) . slot)`. The key is not
	/// stored anywhere; it becomes a template parameter the debugger must bind.
	SemanticDebugPointer buildMapping(
		MappingType const& _mappingType,
		PointerExpression _slot,
		std::string const& _name
	)
	{
		std::string const keyParameter = m_expectedParameters.empty()
			? "key"
			: "key" + std::to_string(m_expectedParameters.size());
		m_expectedParameters.emplace_back(keyParameter);

		PointerExpression keyExpression = PointerExpression::variable(keyParameter);
		// Value-type keys are hashed as full words; bytes and string keys are
		// hashed as their raw bytes.
		if (_mappingType.keyType()->isValueType())
			keyExpression = PointerExpression::wordSized(std::move(keyExpression));

		PointerExpression valueSlot = PointerExpression::keccak256({
			std::move(keyExpression),
			PointerExpression::wordSized(std::move(_slot))
		});
		return build(*_mappingType.valueType(), std::move(valueSlot), std::nullopt, _name);
	}

	/// Dynamic arrays store their element count in the base slot and their data
	/// starting at `keccak256(slot)`.
	SemanticDebugPointer buildDynamicArray(
		ArrayType const& _arrayType,
		PointerExpression _slot,
		std::string const& _name
	)
	{
		std::string const lengthName = _name + "-length";
		std::string const dataVariable = _name + "-data";

		SemanticDebugPointer lengthRegion = SemanticDebugPointer::region(m_location, lengthName, _slot);
		SemanticDebugPointer elements = SemanticDebugPointer::scope(
			{{dataVariable, PointerExpression::keccak256({PointerExpression::wordSized(std::move(_slot))})}},
			elementList(
				_arrayType,
				PointerExpression::variable(dataVariable),
				PointerExpression::read(lengthName),
				_name
			)
		);

		std::vector<SemanticDebugPointer> members;
		members.emplace_back(std::move(lengthRegion));
		members.emplace_back(std::move(elements));
		return SemanticDebugPointer::makeGroup(std::move(members));
	}

	SemanticDebugPointer buildStaticArray(
		ArrayType const& _arrayType,
		PointerExpression _slot,
		std::string const& _name
	)
	{
		return elementList(_arrayType, std::move(_slot), literalExpression(_arrayType.length()), _name);
	}

	/// A list of element pointers laid out from @a _dataStart. Value-type
	/// elements narrower than a word are packed multiple to a slot; everything
	/// else advances in whole slots.
	SemanticDebugPointer elementList(
		ArrayType const& _arrayType,
		PointerExpression _dataStart,
		PointerExpression _count,
		std::string const& _name
	)
	{
		Type const& elementType = *_arrayType.baseType();
		std::string const indexName = _name + "-index";
		std::string const elementName = _name + "-item";
		PointerExpression index = PointerExpression::variable(indexName);

		SemanticDebugPointer element;
		if (elementType.storageBytes() < 32)
		{
			solAssert(elementType.isValueType(), "Only value types can be packed.");
			u256 const elementBytes = elementType.storageBytes();
			u256 const elementsPerSlot = 32 / elementBytes;
			element = SemanticDebugPointer::region(
				m_location,
				elementName,
				PointerExpression::sum({
					std::move(_dataStart),
					PointerExpression::quotient(index, literalExpression(elementsPerSlot))
				}),
				PointerExpression::product({
					PointerExpression::remainder(index, literalExpression(elementsPerSlot)),
					literalExpression(elementBytes)
				}),
				literalExpression(elementBytes)
			);
		}
		else
		{
			u256 const slotsPerElement = elementType.storageSize();
			PointerExpression stride = slotsPerElement == 1
				? index
				: PointerExpression::product({index, literalExpression(slotsPerElement)});
			PointerExpression elementSlot = PointerExpression::sum({std::move(_dataStart), std::move(stride)});
			element = build(elementType, std::move(elementSlot), std::nullopt, elementName);
		}

		return SemanticDebugPointer::list(std::move(_count), indexName, std::move(element));
	}

	/// `bytes` and `string` use the compact encoding: short values keep their
	/// data in the base slot with the doubled length in the last byte; long
	/// values keep `2 * length + 1` in the base slot and their data starting at
	/// `keccak256(slot)`.
	SemanticDebugPointer buildBytesOrString(PointerExpression _slot, std::string const& _name)
	{
		std::string const lengthFlagName = _name + "-length-flag";
		std::string const longLengthName = _name + "-long-length";
		std::string const lengthVariable = _name + "-length";
		std::string const dataVariable = _name + "-data";

		SemanticDebugPointer lengthFlagRegion = SemanticDebugPointer::region(
			m_location,
			lengthFlagName,
			_slot,
			PointerExpression::difference(PointerExpression::wordSize(), literalExpression(1)),
			literalExpression(1)
		);

		SemanticDebugPointer shortValue = SemanticDebugPointer::scope(
			{{lengthVariable, PointerExpression::quotient(PointerExpression::read(lengthFlagName), literalExpression(2))}},
			SemanticDebugPointer::region(
				m_location,
				_name,
				_slot,
				std::nullopt,
				PointerExpression::variable(lengthVariable)
			)
		);

		SemanticDebugPointer longLengthRegion = SemanticDebugPointer::region(m_location, longLengthName, _slot);
		SemanticDebugPointer longData = SemanticDebugPointer::scope(
			{
				{
					lengthVariable,
					PointerExpression::quotient(
						PointerExpression::difference(PointerExpression::read(longLengthName), literalExpression(1)),
						literalExpression(2)
					)
				},
				{dataVariable, PointerExpression::keccak256({PointerExpression::wordSized(std::move(_slot))})}
			},
			SemanticDebugPointer::region(
				m_location,
				_name,
				PointerExpression::variable(dataVariable),
				std::nullopt,
				PointerExpression::variable(lengthVariable)
			)
		);
		std::vector<SemanticDebugPointer> longMembers;
		longMembers.emplace_back(std::move(longLengthRegion));
		longMembers.emplace_back(std::move(longData));

		// The flag byte is even (2 * length) for short values and odd
		// (2 * length + 1) for long ones, so `(flag + 1) % 2` selects short.
		SemanticDebugPointer value = SemanticDebugPointer::conditional(
			PointerExpression::remainder(
				PointerExpression::sum({PointerExpression::read(lengthFlagName), literalExpression(1)}),
				literalExpression(2)
			),
			std::move(shortValue),
			SemanticDebugPointer::makeGroup(std::move(longMembers))
		);

		std::vector<SemanticDebugPointer> members;
		members.emplace_back(std::move(lengthFlagRegion));
		members.emplace_back(std::move(value));
		return SemanticDebugPointer::makeGroup(std::move(members));
	}

	SemanticDebugPointer buildStruct(
		StructType const& _structType,
		PointerExpression _slot,
		std::string const& _name
	)
	{
		// Recursive structs and pathological nesting fall back to a region
		// covering the struct's slots.
		if (m_depth >= maxCompositionDepth || m_structsOnPath.count(_structType.identifier()))
			return wholeRegion(_structType, std::move(_slot), std::nullopt, _name);

		m_structsOnPath.insert(_structType.identifier());
		++m_depth;

		std::vector<SemanticDebugPointer> members;
		for (ASTPointer<VariableDeclaration> const& member: _structType.structDefinition().members())
		{
			if (!member->annotation().type)
				continue;
			auto const& [slotOffset, byteOffset] = _structType.storageOffsetsOfMember(member->name());
			std::optional<PointerExpression> offset;
			if (byteOffset != 0)
				offset = literalExpression(byteOffset);
			members.emplace_back(build(
				*member->annotation().type,
				advanceSlots(_slot, slotOffset),
				std::move(offset),
				_name + "-" + member->name()
			));
		}

		--m_depth;
		m_structsOnPath.erase(_structType.identifier());

		if (members.empty())
			return wholeRegion(_structType, std::move(_slot), std::nullopt, _name);
		return SemanticDebugPointer::makeGroup(std::move(members));
	}

	static constexpr unsigned maxCompositionDepth = 16;

	SemanticDebugPointer::Location m_location;
	std::vector<std::string> m_expectedParameters;
	std::set<std::string> m_structsOnPath;
	unsigned m_depth = 0;
};

SemanticDebugPointer stateVariablePointer(
	VariableDeclaration const& _variable,
	u256 const& _slot,
	unsigned _offset,
	SemanticDebugPointer::Location _location
)
{
	solAssert(_variable.annotation().type, "State variable type expected.");

	StateVariablePointerBuilder builder{_location};
	std::optional<PointerExpression> offset;
	if (_offset != 0)
		offset = literalExpression(_offset);
	SemanticDebugPointer result = builder.build(
		*_variable.annotation().type,
		literalExpression(_slot),
		std::move(offset),
		identifier(_variable.name())
	);
	result.expectedParameters = builder.takeExpectedParameters();
	return result;
}

/// The record of @a _variable without its phase and pointer: identity, source
/// range and, when the type has a document, the type reference.
SemanticDebugVariable variableRecord(TypeRegistry& _types, VariableDeclaration const& _variable)
{
	SemanticDebugVariable result;
	result.identifier = sourceIdentifier(_variable);
	result.declarationASTID = _variable.id();
	result.declarationSourceRange =
		SemanticDebugSourceRange::fromLocation(_variable.location(), sourceID(_types, _variable.location()));
	if (_variable.annotation().type && registerTypeDocument(_types, *_variable.annotation().type))
		result.typeID = _variable.annotation().type->identifier();
	return result;
}

/// The record of a parameter or return variable, materialized in the Yul locals
/// of its stack slots.
SemanticDebugVariable stackVariableRecord(TypeRegistry& _types, VariableDeclaration const& _variable)
{
	SemanticDebugVariable result = variableRecord(_types, _variable);
	// A value without stack slots has nothing to materialize.
	if (std::optional<SemanticDebugPointer> pointer = stackPointer(_variable))
	{
		result.phase = SemanticDebugVariablePhase::Materialized;
		result.pointer = std::move(*pointer);
	}
	else
		result.phase = SemanticDebugVariablePhase::OptimizedOut;
	return result;
}

/// The record of a state variable. Its pointer is a reusable template published
/// in the pointer resources under a producer-defined name; the record
/// references it the same way it references its type.
SemanticDebugVariable stateVariableRecord(
	TypeRegistry& _types,
	SemanticDebugDataTable& _table,
	ContractDefinition const& _contract,
	VariableDeclaration const& _variable,
	u256 const& _slot,
	unsigned _offset,
	SemanticDebugPointer::Location _location
)
{
	SemanticDebugVariable result = variableRecord(_types, _variable);
	std::string const templateName = stateVariablePointerTemplateName(_contract, _variable, _location);
	_table.setPointerTemplate(templateName, stateVariablePointer(_variable, _slot, _offset, _location));
	result.phase = SemanticDebugVariablePhase::Materialized;
	result.pointer = SemanticDebugPointer::templateReference(templateName);
	return result;
}

void appendStackVariables(
	TypeRegistry& _types,
	std::vector<SemanticDebugVariable>& _variables,
	std::vector<ASTPointer<VariableDeclaration>> const& _declarations
)
{
	for (ASTPointer<VariableDeclaration> const& declaration: _declarations)
		_variables.emplace_back(stackVariableRecord(_types, *declaration));
}

void setScope(SemanticDebugDataTable& _table, int64_t _astID, std::vector<SemanticDebugVariable> _variables)
{
	if (_variables.empty())
		return;
	_table.set(_astID, std::make_shared<SemanticDebugScope const>(SemanticDebugScope{
		.variableDefinitions = std::move(_variables)
	}));
}

/// The scope of a function: its parameters and return variables, in that order.
void addFunction(TypeRegistry& _types, SemanticDebugDataTable& _table, FunctionDefinition const& _function)
{
	std::vector<SemanticDebugVariable> variables;
	appendStackVariables(_types, variables, _function.parameters());
	appendStackVariables(_types, variables, _function.returnParameters());
	setScope(_table, _function.id(), std::move(variables));
}

/// The scope of a modifier: its parameters.
void addModifier(TypeRegistry& _types, SemanticDebugDataTable& _table, ModifierDefinition const& _modifier)
{
	std::vector<SemanticDebugVariable> variables;
	appendStackVariables(_types, variables, _modifier.parameters());
	setScope(_table, _modifier.id(), std::move(variables));
}

/// The scope of the contract: its state variables in storage and in transient
/// storage, each with a pointer template in the resources.
void addStateVariables(TypeRegistry& _types, SemanticDebugDataTable& _table, ContractDefinition const& _contract)
{
	auto const* typeType = dynamic_cast<TypeType const*>(_contract.type());
	solAssert(typeType, "Contract TypeType expected.");
	auto const* contractType = dynamic_cast<ContractType const*>(typeType->actualType());
	solAssert(contractType, "Contract type expected.");

	std::vector<SemanticDebugVariable> variables;
	auto append = [&](DataLocation _dataLocation, SemanticDebugPointer::Location _location) {
		for (auto const& [variable, slot, offset]: contractType->linearizedStateVariables(_dataLocation))
			if (!variable->name().empty())
				variables.emplace_back(stateVariableRecord(_types, _table, _contract, *variable, slot, offset, _location));
	};
	append(DataLocation::Storage, SemanticDebugPointer::Location::Storage);
	append(DataLocation::Transient, SemanticDebugPointer::Location::Transient);
	setScope(_table, _contract.id(), std::move(variables));
}

}

SemanticDebugDataTable solidity::frontend::buildSemanticDebugDataTable(
	ContractDefinition const& _contract,
	std::map<std::string, unsigned> const& _sourceIndices
)
{
	SemanticDebugDataTable table;
	table.setContractName(_contract.name());

	TypeRegistry types{{}, &_sourceIndices};
	addStateVariables(types, table, _contract);

	// Inherited functions and modifiers are compiled into the most derived
	// contract's IR with the AST IDs of their original definitions, so every
	// linearized base contract contributes its scopes.
	for (ContractDefinition const* contract: _contract.annotation().linearizedBaseContracts)
	{
		for (FunctionDefinition const* function: contract->definedFunctions())
			addFunction(types, table, *function);
		for (ModifierDefinition const* modifier: contract->functionModifiers())
			addModifier(types, table, *modifier);
	}

	// Free functions and internal library functions reachable through imports
	// are compiled into the contract's IR as well. A library's external
	// functions live in the library's own IR and are covered by its own table.
	SourceUnit const& sourceUnit = _contract.sourceUnit();
	std::set<SourceUnit const*> sourceUnits = sourceUnit.referencedSourceUnits(true);
	sourceUnits.insert(&sourceUnit);
	for (SourceUnit const* unit: sourceUnits)
		for (ASTPointer<ASTNode> const& node: unit->nodes())
		{
			if (auto const* freeFunction = dynamic_cast<FunctionDefinition const*>(node.get()))
				addFunction(types, table, *freeFunction);
			else if (auto const* library = dynamic_cast<ContractDefinition const*>(node.get()); library && library->isLibrary())
				for (FunctionDefinition const* function: library->definedFunctions())
					if (function->visibility() <= Visibility::Internal)
						addFunction(types, table, *function);
		}

	for (auto& [id, document]: types.documents)
		table.setType(id, std::move(document));

	return table;
}
