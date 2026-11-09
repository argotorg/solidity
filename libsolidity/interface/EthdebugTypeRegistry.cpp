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

#include <libsolidity/interface/EthdebugTypeRegistry.h>

#include <libsolidity/ast/AST.h>
#include <libsolidity/ast/ASTVisitor.h>
#include <libsolidity/ast/TypeProvider.h>
#include <libsolidity/ast/Types.h>

#include <libsolutil/Numeric.h>

using namespace solidity;
using namespace solidity::langutil;
using namespace solidity::frontend;
using namespace solidity::frontend::ethdebug;

namespace schema = solidity::langutil::ethdebug::schema;

TypeRegistry::TypeRegistry(std::map<std::string, unsigned> const& _sourceIndices):
	m_sourceIndices(_sourceIndices)
{}

void TypeRegistry::registerTypeDecomposition(Type const& _type)
{
	Type const& canonicalType = canonicalizeType(_type);
	std::string const typeIdentifier = canonicalType.identifier();
	if (m_documents.contains(typeIdentifier))
		return;
	// Present before descending, so that a recursive type terminates.
	m_documents.emplace(typeIdentifier, schema::Type{schema::Type::Bool{}});
	m_documents.insert_or_assign(typeIdentifier, buildTypeDocument(canonicalType));
}

void TypeRegistry::registerVariableTypes(ASTNode const& _node)
{
	SimpleASTVisitor visitor{
		[&](ASTNode const& _child) {
			if (auto const* variable = dynamic_cast<VariableDeclaration const*>(&_child))
			{
				solAssert(variable->type(), "Variable without a type.");
				registerTypeDecomposition(*variable->type());
				return false;
			}
			return true;
		},
		[](ASTNode const&) {},
	};
	_node.accept(visitor);
}

void TypeRegistry::registerCallableTypes(CallableDeclaration const& _callable)
{
	auto const registerParameterListTuple = [&](ParameterList const& _parameterList) {
		TypePointers parameterTypes;
		for (ASTPointer<VariableDeclaration> const& parameter: _parameterList.parameters())
		{
			solAssert(parameter->type(), "Parameter without a type.");
			parameterTypes.push_back(parameter->type());
		}
		registerTypeDecomposition(*TypeProvider::tuple(parameterTypes));
	};
	registerParameterListTuple(_callable.parameterList());
	if (auto const& returnParameterList = _callable.returnParameterList();
		returnParameterList && !returnParameterList->parameters().empty()
	)
		registerParameterListTuple(*returnParameterList);
	registerVariableTypes(_callable);
}

Type const& TypeRegistry::canonicalizeType(Type const& _type)
{
	solAssert(_type.category() != Type::Category::ArraySlice, "A variable cannot have an array slice type.");
	return *TypeProvider::withLocationIfReference(DataLocation::Storage, &_type);
}

schema::materials::SourceRange TypeRegistry::buildSourceRange(SourceLocation const& _location) const
{
	solAssert(_location.hasText(), "Declaration without a source location.");
	auto const sourceIndexIt = m_sourceIndices.find(*_location.sourceName);
	solAssert(sourceIndexIt != m_sourceIndices.end(), "Declaration source is not in the compilation.");

	return schema::materials::SourceRange{
		.source = {
			.id = schema::materials::ID{static_cast<uint64_t>(sourceIndexIt->second)},
			.type = schema::materials::Reference::Type::Source,
		},
		.range = schema::materials::SourceRange::Range{
			.length = schema::data::Unsigned{_location.end - _location.start},
			.offset = schema::data::Unsigned{_location.start},
		},
	};
}

schema::Type::Definition TypeRegistry::buildTypeDefinition(Declaration const& _declaration) const
{
	solAssert(!_declaration.name().empty(), "Type declaration without a name.");
	return schema::Type::Definition{
		_declaration.name(),
		buildSourceRange(_declaration.location()),
	};
}

schema::Type::Wrapper TypeRegistry::registerAndWrapType(std::optional<std::string> _name, Type const& _type)
{
	registerTypeDecomposition(_type);
	return schema::Type::Wrapper{
		.name = std::move(_name),
		.type = schema::Type::Specifier{schema::Type::Reference{schema::materials::ID{canonicalizeType(_type).identifier()}}},
	};
}

std::vector<schema::Type::Wrapper> TypeRegistry::registerAndWrapTypes(std::vector<Type const*> const& _types)
{
	std::vector<schema::Type::Wrapper> typeWrappers;
	for (Type const* componentType: _types)
	{
		solAssert(componentType, "Tuple component without a type.");
		typeWrappers.push_back(registerAndWrapType(std::nullopt, *componentType));
	}
	return typeWrappers;
}

schema::Type TypeRegistry::buildTypeDocument(Type const& _canonicalType)
{
	switch (_canonicalType.category())
	{
	case Type::Category::Address:
	{
		auto const& addressType = dynamic_cast<AddressType const&>(_canonicalType);
		solAssert(
			addressType.stateMutability() == StateMutability::Payable || addressType.stateMutability() == StateMutability::NonPayable,
			"An address is either payable or non-payable."
		);
		return schema::Type{schema::Type::Address{.payable = addressType.stateMutability() == StateMutability::Payable}};
	}
	case Type::Category::Integer:
	{
		auto const& integerType = dynamic_cast<IntegerType const&>(_canonicalType);
		if (integerType.isSigned())
			return schema::Type{schema::Type::Int{integerType.numBits()}};
		return schema::Type{schema::Type::UInt{integerType.numBits()}};
	}
	case Type::Category::FixedPoint:
	{
		auto const& fixedPointType = dynamic_cast<FixedPointType const&>(_canonicalType);
		if (fixedPointType.isSigned())
			return schema::Type{schema::Type::Fixed{fixedPointType.numBits(), fixedPointType.fractionalDigits()}};
		return schema::Type{schema::Type::UFixed{fixedPointType.numBits(), fixedPointType.fractionalDigits()}};
	}
	case Type::Category::Bool:
		return schema::Type{schema::Type::Bool{}};
	case Type::Category::FixedBytes:
	{
		auto const& bytesType = dynamic_cast<FixedBytesType const&>(_canonicalType);
		return schema::Type{schema::Type::Bytes{.size = schema::data::Unsigned{bytesType.numBytes()}}};
	}
	case Type::Category::Array:
	{
		auto const& arrayType = dynamic_cast<ArrayType const&>(_canonicalType);
		if (arrayType.isString())
			return schema::Type{schema::Type::String{}};
		if (arrayType.isByteArray())
			return schema::Type{schema::Type::Bytes{}};
		std::optional<schema::data::Unsigned> count;
		if (!arrayType.isDynamicallySized())
			count = schema::data::Unsigned{schema::data::HexValue{toCompactBigEndian(arrayType.length(), 1)}};
		return schema::Type{schema::Type::Array{
			.contains = registerAndWrapType(std::nullopt, *arrayType.baseType()),
			.count = std::move(count),
		}};
	}
	case Type::Category::Contract:
	{
		auto const& contractType = dynamic_cast<ContractType const&>(_canonicalType);
		ContractDefinition const& contract = contractType.contractDefinition();
		schema::Type::Contract::Kind kind = schema::Type::Contract::Kind::Contract;
		if (contract.isLibrary())
			kind = schema::Type::Contract::Kind::Library;
		else if (contract.isInterface())
			kind = schema::Type::Contract::Kind::Interface;
		return schema::Type{schema::Type::Contract{
			.kind = kind,
			.payable = contractType.isPayable(),
			.definition = buildTypeDefinition(contract),
		}};
	}
	case Type::Category::Struct:
	{
		// The members carry the types they have in the struct's data location,
		// e.g. a `string` member of a storage struct is a storage string.
		auto const& structType = dynamic_cast<StructType const&>(_canonicalType);
		std::vector<schema::Type::Wrapper> members;
		for (MemberList::Member const& member: structType.members(nullptr))
			members.push_back(registerAndWrapType(member.name, *member.type));
		return schema::Type{schema::Type::Struct{
			.contains = std::move(members),
			.definition = buildTypeDefinition(structType.structDefinition()),
		}};
	}
	case Type::Category::Enum:
	{
		auto const& enumType = dynamic_cast<EnumType const&>(_canonicalType);
		std::vector<std::string> values;
		for (ASTPointer<EnumValue> const& member: enumType.enumDefinition().members())
			values.emplace_back(member->name());
		return schema::Type{schema::Type::Enum{
			.values = std::move(values),
			.definition = buildTypeDefinition(enumType.enumDefinition()),
		}};
	}
	case Type::Category::UserDefinedValueType:
	{
		auto const& userDefinedValueType = dynamic_cast<UserDefinedValueType const&>(_canonicalType);
		return schema::Type{schema::Type::Alias{
			.contains = registerAndWrapType(std::nullopt, userDefinedValueType.underlyingType()),
			.definition = buildTypeDefinition(userDefinedValueType.definition()),
		}};
	}
	case Type::Category::Tuple:
	{
		auto const& tupleType = dynamic_cast<TupleType const&>(_canonicalType);
		return schema::Type{schema::Type::Tuple{.contains = registerAndWrapTypes(tupleType.components())}};
	}
	case Type::Category::Mapping:
	{
		auto const& mappingType = dynamic_cast<MappingType const&>(_canonicalType);
		return schema::Type{schema::Type::Mapping{
			.key = registerAndWrapType(std::nullopt, *mappingType.keyType()),
			.value = registerAndWrapType(std::nullopt, *mappingType.valueType()),
		}};
	}
	case Type::Category::Function:
	{
		// Of the kinds of functions, only internal and external ones are values
		// a variable can hold.
		auto const& functionType = dynamic_cast<FunctionType const&>(_canonicalType);
		solAssert(!functionType.hasDeclaration(), "A variable's function type has no declaration.");
		solAssert(
			functionType.kind() == FunctionType::Kind::Internal || functionType.kind() == FunctionType::Kind::External,
			"Only internal and external function types are nameable."
		);

		// The parameter and return lists are tuple types, documented and
		// referenced like any other type.
		auto const registerAndWrapTuple = [&](std::vector<Type const*> const& _types) {
			return registerAndWrapType(std::nullopt, *TypeProvider::tuple(_types));
		};
		schema::Type::Wrapper parameters = registerAndWrapTuple(functionType.parameterTypes());
		std::optional<schema::Type::Wrapper> returns;
		if (!functionType.returnParameterTypes().empty())
			returns = registerAndWrapTuple(functionType.returnParameterTypes());
		return schema::Type{schema::Type::Function{
			.visibility = functionType.kind() == FunctionType::Kind::Internal ?
				schema::Type::Function::Visibility::Internal :
				schema::Type::Function::Visibility::External,
			.parameters = std::move(parameters),
			.returns = std::move(returns),
			.definition = std::nullopt,
		}};
	}
	case Type::Category::RationalNumber:
	case Type::Category::ArraySlice:
	case Type::Category::StringLiteral:
	case Type::Category::TypeType:
	case Type::Category::Modifier:
	case Type::Category::Magic:
	case Type::Category::Module:
	case Type::Category::InaccessibleDynamic:
		solAssert(false, "Unnameable types cannot be variable types.");
	}
	solAssert(false, "");
}
