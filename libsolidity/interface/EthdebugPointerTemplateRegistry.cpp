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

#include <libsolidity/interface/EthdebugPointerTemplateRegistry.h>
#include <libsolidity/interface/EthdebugTypeRegistry.h>

#include <libsolidity/ast/AST.h>
#include <libsolidity/ast/ASTVisitor.h>
#include <libsolidity/ast/TypeProvider.h>
#include <libsolidity/ast/Types.h>

#include <libsolutil/Assertions.h>
#include <libsolutil/CommonData.h>
#include <libsolutil/Numeric.h>
#include <libsolutil/Visitor.h>

#include <memory>
#include <optional>
#include <utility>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::frontend;
using namespace solidity::frontend::ethdebug;

namespace schema = solidity::langutil::ethdebug::schema;

namespace
{

using Pointer = schema::Pointer;
using VariableDefinition = std::pair<std::string, Pointer::Expression>;

namespace pointer
{

// Constructs schema pointer expressions and pointers, not AST nodes.

Pointer::Expression literal(u256 const& _value)
{
	return {Pointer::Literal{schema::data::Unsigned{schema::data::HexValue{toCompactBigEndian(_value, 1)}}}};
}

Pointer::Expression variable(std::string _name)
{
	return {Pointer::Variable{std::move(_name)}};
}

Pointer::Expression wordSize()
{
	return {Pointer::Constant::WordSize};
}

Pointer::Expression read(std::string _regionName)
{
	return {Pointer::Read{std::move(_regionName)}};
}

Pointer::Expression arithmetic(Pointer::Arithmetic::Operator _operator, Pointer::Expression _left, Pointer::Expression _right)
{
	return {Pointer::Arithmetic{_operator, make_vector<Pointer::Expression>(std::move(_left), std::move(_right))}};
}

Pointer::Expression sum(Pointer::Expression _left, Pointer::Expression _right)
{
	return arithmetic(Pointer::Arithmetic::Operator::Sum, std::move(_left), std::move(_right));
}

Pointer::Expression product(Pointer::Expression _left, Pointer::Expression _right)
{
	return arithmetic(Pointer::Arithmetic::Operator::Product, std::move(_left), std::move(_right));
}

Pointer::Expression difference(Pointer::Expression _minuend, Pointer::Expression _subtrahend)
{
	return arithmetic(Pointer::Arithmetic::Operator::Difference, std::move(_minuend), std::move(_subtrahend));
}

Pointer::Expression quotient(Pointer::Expression _dividend, Pointer::Expression _divisor)
{
	return arithmetic(Pointer::Arithmetic::Operator::Quotient, std::move(_dividend), std::move(_divisor));
}

Pointer::Expression remainder(Pointer::Expression _dividend, Pointer::Expression _divisor)
{
	return arithmetic(Pointer::Arithmetic::Operator::Remainder, std::move(_dividend), std::move(_divisor));
}

Pointer::Expression keccak256(Pointer::Operands _operands)
{
	return {Pointer::Keccak256{std::move(_operands)}};
}

Pointer::Expression wordSized(Pointer::Expression _operand)
{
	return {Pointer::Resize{std::nullopt, std::make_unique<Pointer::Expression const>(std::move(_operand))}};
}

Pointer region(
	Pointer::Location _location,
	std::optional<std::string> _name,
	Pointer::Expression _slot,
	std::optional<Pointer::Expression> _bigEndianOffset = std::nullopt,
	std::optional<Pointer::Expression> _length = std::nullopt
)
{
	return {Pointer::Region{std::move(_name), _location, std::move(_slot), std::move(_bigEndianOffset), std::move(_length)}};
}

Pointer::Location location(DataLocation _location)
{
	switch (_location)
	{
	case DataLocation::Storage:
		return Pointer::Location::Storage;
	case DataLocation::Transient:
		return Pointer::Location::Transient;
	case DataLocation::Memory:
		return Pointer::Location::Memory;
	case DataLocation::CallData:
		return Pointer::Location::Calldata;
	}
	solAssert(false, "Unsupported pointer layout.");
	unreachable();
}

Pointer byteRegion(DataLocation _location, std::string const& _name, Pointer::Expression _offset, Pointer::Expression _length)
{
	return {Pointer::Region{_name, location(_location), std::nullopt, std::move(_offset), std::move(_length)}};
}

Pointer group(std::vector<Pointer> _members)
{
	return {Pointer::Group{std::move(_members)}};
}

Pointer list(Pointer::Expression _count, std::string _each, Pointer _element)
{
	return {Pointer::List{std::move(_count), std::move(_each), std::make_unique<Pointer const>(std::move(_element))}};
}

Pointer conditional(Pointer::Expression _condition, Pointer _then, Pointer _otherwise)
{
	return {Pointer::Conditional{
		std::move(_condition),
		std::make_unique<Pointer const>(std::move(_then)),
		std::make_unique<Pointer const>(std::move(_otherwise)),
	}};
}

Pointer scope(std::vector<VariableDefinition> _definitions, Pointer _in)
{
	return {Pointer::Scope{std::move(_definitions), std::make_unique<Pointer const>(std::move(_in))}};
}

/// Adds @a _offset to @a _base, folding the addition when the base is a literal.
Pointer::Expression addLiteralOffset(Pointer::Expression _base, u256 const& _offset)
{
	if (_offset == 0)
		return _base;
	if (auto const* literalBase = std::get_if<Pointer::Literal>(&_base.value))
	{
		u256 const base = std::visit(GenericVisitor{
			[](std::uint64_t const _value) { return u256(_value); },
			[](schema::data::HexValue const& _value) { return fromBigEndian<u256>(_value.value); },
		}, literalBase->value.value);
		return literal(base + _offset);
	}
	return sum(std::move(_base), literal(_offset));
}

/// A single region covering a value of value type as laid out in its slot,
/// in storage or transient storage.
///
/// A region uses a big-endian byte offset, while the storage layout uses a
/// little-endian byte offset. For a value of n bytes, these offsets sum to
/// 32 - n. A region without an offset and a length covers the whole slot.
Pointer buildValueRegion(
	Type const& _type,
	Pointer::Location _location,
	Pointer::Expression _slot,
	unsigned _littleEndianOffset,
	std::optional<std::string> _name
)
{
	solAssert(_type.isValueType(), "A value region requires a value type.");
	solAssert(_littleEndianOffset < 32, "A little-endian offset must be within its slot.");
	solAssert(_type.storageSize() == 1, "A value type fits one slot.");
	u256 const byteLength = _type.storageBytes();
	solAssert(byteLength > 0 && byteLength <= 32, "A value type occupies between 1 and 32 bytes.");
	if (byteLength == 32)
	{
		solAssert(_littleEndianOffset == 0, "A whole word cannot be packed.");
		return region(_location, std::move(_name), std::move(_slot));
	}
	solAssert(_littleEndianOffset + byteLength <= 32, "A packed value does not fit its slot.");
	u256 const bigEndianOffset = 32 - _littleEndianOffset - byteLength;
	std::optional<Pointer::Expression> bigEndianOffsetExpression;
	if (bigEndianOffset != 0)
		bigEndianOffsetExpression = literal(bigEndianOffset);
	return region(_location, std::move(_name), std::move(_slot), std::move(bigEndianOffsetExpression), literal(byteLength));
}

}

}

void PointerTemplateRegistry::registerVariableTypes(ASTNode const& _node)
{
	if (auto const* declaration = dynamic_cast<ImplementationOptional const*>(&_node);
		declaration && !declaration->isImplemented()
	)
		return;
	SimpleASTVisitor visitor{
		[&](ASTNode const& _child) {
			if (auto const* variable = dynamic_cast<VariableDeclaration const*>(&_child))
			{
				solAssert(variable->type(), "Variable without an annotated type.");
				Type const& declaredType = *variable->type();
				if (auto const* referenceType = dynamic_cast<ReferenceType const*>(&declaredType))
					registerType(declaredType, referenceType->location());
				else if (dynamic_cast<MappingType const*>(&declaredType))
					registerType(declaredType, DataLocation::Storage);
				else
					solAssert(declaredType.isValueType(), "Expected a variable type.");
				return false;
			}
			return true;
		},
		[](ASTNode const&) {},
	};
	_node.accept(visitor);
}

std::string PointerTemplateRegistry::identifier(Type const& _type, DataLocation _location)
{
	std::string const typeIdentifier = TypeRegistry::canonicalizeType(_type).identifier();
	switch (_location)
	{
	case DataLocation::Storage:
		return "storage-" + typeIdentifier;
	case DataLocation::Transient:
		return "transient-" + typeIdentifier;
	case DataLocation::Memory:
		return "memory-" + typeIdentifier;
	case DataLocation::CallData:
		return "calldata-" + typeIdentifier;
	}
	solAssert(false, "Unsupported pointer layout.");
	unreachable();
}

void PointerTemplateRegistry::registerType(Type const& _type, DataLocation _location)
{
	std::string const id = identifier(_type, _location);
	// A recursive type references its own template, which is being
	// built; the reference is resolved lazily by the consumer.
	if (m_templateDrafts.contains(id) || m_templateIDsBeingBuilt.contains(id))
		return;
	collectTemplateTypes(_type, _location);
	// Always choose the next pending layout by pointer ID, including in recursive
	// calls. This makes the yields of recursive references independent of which
	// state variable was registered first.
	while (!m_pendingTemplateTypes.empty())
	{
		auto const nextTemplateType = m_pendingTemplateTypes.begin();
		std::string const templateID = nextTemplateType->first;
		auto const [templateType, templateLocation] = nextTemplateType->second;
		m_pendingTemplateTypes.erase(nextTemplateType);
		m_templateIDsBeingBuilt.insert(templateID);
		TemplateDraft templateDraft = buildTemplate(*templateType, templateLocation);
		m_templateIDsBeingBuilt.erase(templateID);
		m_templateDrafts.emplace(templateID, std::move(templateDraft));
	}
}

void PointerTemplateRegistry::collectTemplateTypes(Type const& _type, DataLocation _location)
{
	solAssert(
		_location == DataLocation::Storage ||
		_location == DataLocation::Transient ||
		_location == DataLocation::Memory ||
		_location == DataLocation::CallData,
		"Unsupported pointer layout."
	);
	solAssert(_location != DataLocation::Transient || _type.isValueType(), "Only value types live in transient storage.");
	Type const& locatedType = *TypeProvider::withLocationIfReference(_location, &_type);
	std::string const id = identifier(locatedType, _location);
	if (
		m_templateDrafts.contains(id) ||
		m_templateIDsBeingBuilt.contains(id) ||
		!m_pendingTemplateTypes.emplace(id, std::make_pair(&locatedType, _location)).second
	)
		return;
	// Value-type components need templates in the enclosing memory or calldata layout too.
	if (locatedType.isValueType())
		return;
	if (auto const* structType = dynamic_cast<StructType const*>(&locatedType))
		for (MemberList::Member const& member: structType->members(nullptr))
			collectTemplateTypes(*member.type, _location);
	else if (auto const* arrayType = dynamic_cast<ArrayType const*>(&locatedType))
	{
		if (!arrayType->isByteArrayOrString())
			collectTemplateTypes(*arrayType->baseType(), _location);
	}
	else if (auto const* mappingType = dynamic_cast<MappingType const*>(&locatedType))
	{
		solAssert(_location == DataLocation::Storage, "Mappings only live in storage.");
		collectTemplateTypes(*mappingType->valueType(), _location);
	}
	else
		solAssert(false, "Only value types, structs, arrays and mappings have pointer templates.");
}

std::map<std::string, Pointer::Template> PointerTemplateRegistry::takeTemplates()
{
	solAssert(m_templateIDsBeingBuilt.empty(), "Cannot take pointer templates during construction.");
	solAssert(m_pendingTemplateTypes.empty(), "Cannot take pointer templates while layouts are pending.");
	std::map<std::string, Pointer::Template> result;
	for (auto& [id, templateDraft]: m_templateDrafts)
		result.emplace(
			id,
			Pointer::Template{
				std::move(templateDraft.expectedParameters),
				std::make_unique<Pointer const>(std::move(templateDraft.body)),
			}
		);
	m_templateDrafts.clear();
	return result;
}

PointerTemplateRegistry::TemplateDraft PointerTemplateRegistry::buildTemplate(Type const& _type, DataLocation _location)
{
	if (_location == DataLocation::Memory || _location == DataLocation::CallData)
		return buildByteAddressedTemplate(_type, _location);
	if (_type.isValueType())
	{
		solAssert(
			_location == DataLocation::Storage || _location == DataLocation::Transient,
			"Expected a storage or transient value-type layout."
		);
		solAssert(_type.storageSize() == 1 && _type.storageBytes() > 0 && _type.storageBytes() <= 32, "A value type fits one slot.");
		// The offset parameter is little-endian; the region's offset is big-endian.
		return TemplateDraft{
			{"slot", "offset"},
			pointer::region(
				pointer::location(_location),
				"value",
				pointer::variable("slot"),
				pointer::difference(pointer::literal(32 - _type.storageBytes()), pointer::variable("offset")),
				pointer::literal(_type.storageBytes())
			),
			{"value"},
		};
	}
	solAssert(_location == DataLocation::Storage, "Only value types live in transient storage.");
	if (auto const* mappingType = dynamic_cast<MappingType const*>(&_type))
		return buildMappingTemplate(*mappingType);
	if (auto const* arrayType = dynamic_cast<ArrayType const*>(&_type))
		return buildArrayTemplate(*arrayType);
	auto const* structType = dynamic_cast<StructType const*>(&_type);
	solAssert(structType, "Only structs, arrays and mappings have templates.");
	return buildStructTemplate(*structType);
}

Pointer PointerTemplateRegistry::buildStorageComponentPointer(
	Type const& _type,
	Pointer::Expression _slot,
	unsigned _littleEndianOffset,
	std::string const& _name,
	std::set<std::string>& _producedRegions
)
{
	solAssert(_littleEndianOffset < 32, "A little-endian offset must be within its slot.");
	if (!_type.isValueType())
	{
		solAssert(_littleEndianOffset == 0, "A reference type starts at the beginning of its slot.");
		registerType(_type, DataLocation::Storage);
		if (dynamic_cast<MappingType const*>(&_type))
		{
			// A mapping's base slot is what its template expects to locate an entry.
			_producedRegions.insert(_name);
			return pointer::region(Pointer::Location::Storage, _name, std::move(_slot));
		}
		Pointer templateReference = buildTemplateReference(_type, DataLocation::Storage, _name, _producedRegions);
		// The referenced template expects the base slot as the `slot` parameter;
		// a value at the enclosing base slot passes it through as it is.
		if (auto const* slot = std::get_if<Pointer::Variable>(&_slot.value);
			slot && slot->identifier == "slot"
		)
			return templateReference;
		return pointer::scope(make_vector<VariableDefinition>(VariableDefinition{"slot", std::move(_slot)}), std::move(templateReference));
	}
	_producedRegions.insert(_name);
	return pointer::buildValueRegion(_type, Pointer::Location::Storage, std::move(_slot), _littleEndianOffset, _name);
}

Pointer PointerTemplateRegistry::buildTemplateReference(
	Type const& _type,
	DataLocation _location,
	std::string const& _name,
	std::set<std::string>& _producedRegions
)
{
	registerType(_type, _location);
	std::string const id = identifier(_type, _location);
	std::vector<std::pair<std::string, std::string>> yields;
	// Names of recursive references pass through until the enclosing template is built.
	if (auto const it = m_templateDrafts.find(id);
		it != m_templateDrafts.end()
	)
		for (std::string const& regionName: it->second.producedRegions)
		{
			std::string const prefixedRegionName = _name + "-" + regionName;
			yields.emplace_back(regionName, prefixedRegionName);
			_producedRegions.insert(prefixedRegionName);
		}
	return {Pointer::TemplateReference{id, std::move(yields)}};
}

Pointer PointerTemplateRegistry::buildByteAddressedComponentPointer(
	Type const& _type,
	DataLocation _location,
	Pointer::Expression _headAddress,
	Pointer::Expression _abiOffsetBase,
	std::string const& _name,
	std::set<std::string>& _producedRegions
)
{
	solAssert(_location == DataLocation::Memory || _location == DataLocation::CallData, "Expected a memory or calldata layout.");
	if (_type.isValueType())
	{
		_producedRegions.insert(_name);
		unsigned const byteLength = _type.storageBytes();
		solAssert(byteLength > 0 && byteLength <= 32, "A value type fits one word.");
		return pointer::byteRegion(
			_location,
			_name,
			pointer::addLiteralOffset(std::move(_headAddress), _type.leftAligned() ? 0 : 32 - byteLength),
			pointer::literal(byteLength)
		);
	}
	Pointer templateReference = buildTemplateReference(_type, _location, _name, _producedRegions);
	if (_location == DataLocation::Memory || _type.isDynamicallyEncoded())
	{
		// Memory heads contain absolute addresses; ABI heads contain offsets
		// relative to the enclosing tuple or array's element area.
		std::string const addressRegionName = _name + "-address";
		_producedRegions.insert(addressRegionName);
		Pointer::Expression targetAddress = _location == DataLocation::Memory ?
			pointer::read(addressRegionName) : pointer::sum(std::move(_abiOffsetBase), pointer::read(addressRegionName));
		return pointer::group(make_vector<Pointer>(
			pointer::byteRegion(_location, addressRegionName, std::move(_headAddress), pointer::literal(32)),
			pointer::scope(make_vector<VariableDefinition>(VariableDefinition{"offset", std::move(targetAddress)}), std::move(templateReference))
		));
	}
	return pointer::scope(make_vector<VariableDefinition>(VariableDefinition{"offset", std::move(_headAddress)}), std::move(templateReference));
}

PointerTemplateRegistry::TemplateDraft PointerTemplateRegistry::buildByteAddressedTemplate(Type const& _type, DataLocation _location)
{
	solAssert(_location == DataLocation::Memory || _location == DataLocation::CallData, "Expected a memory or calldata layout.");
	std::set<std::string> producedRegions;
	if (_type.isValueType())
	{
		Pointer valuePointer = buildByteAddressedComponentPointer(
			_type,
			_location,
			pointer::variable("offset"),
			pointer::literal(0),
			"value",
			producedRegions
		);
		return TemplateDraft{{"offset"}, std::move(valuePointer), std::move(producedRegions)};
	}
	if (auto const* structType = dynamic_cast<StructType const*>(&_type))
	{
		std::vector<Pointer> members;
		for (MemberList::Member const& member: structType->members(nullptr))
		{
			u256 const memberByteOffset = _location == DataLocation::Memory ?
				structType->memoryOffsetOfMember(member.name) : structType->calldataOffsetOfMember(member.name);
			members.emplace_back(buildByteAddressedComponentPointer(
				*member.type,
				_location,
				pointer::addLiteralOffset(pointer::variable("offset"), memberByteOffset),
				pointer::variable("offset"),
				member.name,
				producedRegions
			));
		}
		return TemplateDraft{{"offset"}, pointer::group(std::move(members)), std::move(producedRegions)};
	}
	auto const* arrayType = dynamic_cast<ArrayType const*>(&_type);
	solAssert(arrayType, "Expected a memory or calldata array.");
	std::vector<Pointer> parts;
	if (arrayType->isDynamicallySized())
	{
		parts.emplace_back(pointer::byteRegion(_location, "length", pointer::variable("offset"), pointer::literal(32)));
		producedRegions.insert("length");
	}
	Pointer::Expression dataStartAddress = pointer::addLiteralOffset(pointer::variable("offset"), arrayType->isDynamicallySized() ? 32 : 0);
	Pointer dataPointer = buildByteAddressedArrayDataPointer(*arrayType, _location, producedRegions);
	parts.emplace_back(pointer::scope(
		make_vector<VariableDefinition>(VariableDefinition{"data", std::move(dataStartAddress)}),
		std::move(dataPointer)
	));
	return TemplateDraft{{"offset"}, pointer::group(std::move(parts)), std::move(producedRegions)};
}

Pointer PointerTemplateRegistry::buildByteAddressedArrayDataPointer(
	ArrayType const& _arrayType,
	DataLocation _location,
	std::set<std::string>& _producedRegions
)
{
	solAssert(_location == DataLocation::Memory || _location == DataLocation::CallData, "Expected a memory or calldata layout.");
	if (_arrayType.isByteArrayOrString())
	{
		_producedRegions.insert("data");
		return pointer::byteRegion(_location, "data", pointer::variable("data"), pointer::read("length"));
	}
	unsigned const elementByteStride = _location == DataLocation::Memory ? _arrayType.memoryStride() : _arrayType.calldataStride();
	Pointer elementPointer = buildByteAddressedComponentPointer(
		*_arrayType.baseType(),
		_location,
		pointer::sum(pointer::variable("data"), pointer::product(pointer::variable("index"), pointer::literal(elementByteStride))),
		pointer::variable("data"),
		"item",
		_producedRegions
	);
	return pointer::list(
		_arrayType.isDynamicallySized() ? pointer::read("length") : pointer::literal(_arrayType.length()),
		"index",
		std::move(elementPointer)
	);
}

PointerTemplateRegistry::TemplateDraft PointerTemplateRegistry::buildStructTemplate(StructType const& _structType)
{
	std::set<std::string> producedRegions;
	std::vector<Pointer> members;
	for (MemberList::Member const& member: _structType.members(nullptr))
	{
		auto const& [slotOffset, littleEndianOffset] = _structType.storageOffsetsOfMember(member.name);
		members.emplace_back(buildStorageComponentPointer(
			*member.type,
			pointer::addLiteralOffset(pointer::variable("slot"), slotOffset),
			littleEndianOffset,
			member.name,
			producedRegions
		));
	}
	solAssert(!members.empty(), "A struct has members.");
	return TemplateDraft{{"slot"}, pointer::group(std::move(members)), std::move(producedRegions)};
}

PointerTemplateRegistry::TemplateDraft PointerTemplateRegistry::buildArrayTemplate(ArrayType const& _arrayType)
{
	std::set<std::string> producedRegions;
	if (_arrayType.isByteArrayOrString())
		return TemplateDraft{
			{"slot"},
			buildBytesOrStringPointer(producedRegions),
			std::move(producedRegions),
		};
	if (_arrayType.isDynamicallySized())
		return TemplateDraft{
			{"slot"},
			buildDynamicArrayPointer(_arrayType, producedRegions),
			std::move(producedRegions),
		};
	return TemplateDraft{
		{"slot"},
		buildArrayElementListPointer(_arrayType, pointer::variable("slot"), pointer::literal(_arrayType.length()), producedRegions),
		std::move(producedRegions),
	};
}

PointerTemplateRegistry::TemplateDraft PointerTemplateRegistry::buildMappingTemplate(MappingType const& _mappingType)
{
	std::set<std::string> producedRegions;
	Pointer::Expression keyExpression = pointer::variable("key");
	// Value-type keys are hashed as full words; bytes and string keys are
	// hashed as their raw bytes.
	if (_mappingType.keyType()->isValueType())
		keyExpression = pointer::wordSized(std::move(keyExpression));
	Pointer::Expression valueSlot = pointer::keccak256(make_vector<Pointer::Expression>(
		std::move(keyExpression),
		pointer::wordSized(pointer::variable("slot"))
	));
	Pointer body = buildStorageComponentPointer(*_mappingType.valueType(), std::move(valueSlot), 0, "value", producedRegions);
	return TemplateDraft{{"slot", "key"}, std::move(body), std::move(producedRegions)};
}

Pointer PointerTemplateRegistry::buildDynamicArrayPointer(ArrayType const& _arrayType, std::set<std::string>& _producedRegions)
{
	Pointer lengthRegion = pointer::region(Pointer::Location::Storage, "length", pointer::variable("slot"));
	_producedRegions.insert("length");
	Pointer elements = pointer::scope(
		make_vector<VariableDefinition>(VariableDefinition{
			"data",
			pointer::keccak256(make_vector<Pointer::Expression>(pointer::wordSized(pointer::variable("slot")))),
		}),
		buildArrayElementListPointer(_arrayType, pointer::variable("data"), pointer::read("length"), _producedRegions)
	);

	std::vector<Pointer> members;
	members.emplace_back(std::move(lengthRegion));
	members.emplace_back(std::move(elements));
	return pointer::group(std::move(members));
}

Pointer PointerTemplateRegistry::buildArrayElementListPointer(
	ArrayType const& _arrayType,
	Pointer::Expression _dataStartSlot,
	Pointer::Expression _elementCount,
	std::set<std::string>& _producedRegions
)
{
	Type const& elementType = *_arrayType.baseType();
	if (elementType.storageBytes() < 32)
	{
		// Packed k to a slot from the least significant byte: element i is
		// in slot i / k, with big-endian offset 32 - (i % k + 1) * size.
		solAssert(elementType.isValueType(), "Only value types can be packed.");
		u256 const elementBytes = elementType.storageBytes();
		u256 const elementsPerSlot = 32 / elementBytes;
		Pointer::Expression littleEndianEndOffset = pointer::sum(
			pointer::remainder(pointer::variable("index"), pointer::literal(elementsPerSlot)),
			pointer::literal(1)
		);
		if (elementBytes != 1)
			littleEndianEndOffset = pointer::product(std::move(littleEndianEndOffset), pointer::literal(elementBytes));
		_producedRegions.insert("item");
		Pointer elementPointer = pointer::region(
			Pointer::Location::Storage,
			"item",
			pointer::sum(std::move(_dataStartSlot), pointer::quotient(pointer::variable("index"), pointer::literal(elementsPerSlot))),
			pointer::difference(pointer::wordSize(), std::move(littleEndianEndOffset)),
			pointer::literal(elementBytes)
		);
		return pointer::list(std::move(_elementCount), "index", std::move(elementPointer));
	}
	u256 const slotsPerElement = elementType.storageSize();
	Pointer::Expression elementSlotOffset = slotsPerElement == 1
		? pointer::variable("index")
		: pointer::product(pointer::variable("index"), pointer::literal(slotsPerElement));
	Pointer elementPointer = buildStorageComponentPointer(
		elementType,
		pointer::sum(std::move(_dataStartSlot), std::move(elementSlotOffset)),
		0,
		"item",
		_producedRegions
	);
	return pointer::list(std::move(_elementCount), "index", std::move(elementPointer));
}

Pointer PointerTemplateRegistry::buildBytesOrStringPointer(std::set<std::string>& _producedRegions)
{
	Pointer lengthFlagRegion = pointer::region(
		Pointer::Location::Storage,
		"length-flag",
		pointer::variable("slot"),
		pointer::difference(pointer::wordSize(), pointer::literal(1)),
		pointer::literal(1)
	);

	Pointer shortValue = pointer::scope(
		make_vector<VariableDefinition>(VariableDefinition{"length", pointer::quotient(pointer::read("length-flag"), pointer::literal(2))}),
		pointer::region(Pointer::Location::Storage, "data", pointer::variable("slot"), std::nullopt, pointer::variable("length"))
	);

	Pointer longLengthRegion = pointer::region(Pointer::Location::Storage, "long-length", pointer::variable("slot"));
	Pointer longData = pointer::scope(
		make_vector<VariableDefinition>(
			VariableDefinition{"length", pointer::quotient(pointer::difference(pointer::read("long-length"), pointer::literal(1)), pointer::literal(2))},
			VariableDefinition{"start", pointer::keccak256(make_vector<Pointer::Expression>(pointer::wordSized(pointer::variable("slot"))))}
		),
		pointer::region(Pointer::Location::Storage, "data", pointer::variable("start"), std::nullopt, pointer::variable("length"))
	);
	std::vector<Pointer> longMembers;
	longMembers.emplace_back(std::move(longLengthRegion));
	longMembers.emplace_back(std::move(longData));

	// The flag byte is even (2 * length) for short values and odd
	// (2 * length + 1) for long ones, so `(flag + 1) % 2` selects short.
	Pointer value = pointer::conditional(
		pointer::remainder(pointer::sum(pointer::read("length-flag"), pointer::literal(1)), pointer::literal(2)),
		std::move(shortValue),
		pointer::group(std::move(longMembers))
	);

	for (char const* name: {"length-flag", "data", "long-length"})
		_producedRegions.insert(name);
	std::vector<Pointer> members;
	members.emplace_back(std::move(lengthFlagRegion));
	members.emplace_back(std::move(value));
	return pointer::group(std::move(members));
}
