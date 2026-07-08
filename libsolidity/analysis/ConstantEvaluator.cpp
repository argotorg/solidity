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
/**
 * @author Christian <c@ethdev.com>
 * @date 2015
 * Evaluator for types of constant expressions.
 */

#include <libsolidity/analysis/ConstantEvaluator.h>

#include <libsolidity/ast/AST.h>
#include <libsolidity/ast/TypeProvider.h>
#include <liblangutil/ErrorReporter.h>
#include <libsolutil/Keccak256.h>
#include <libsolutil/StringUtils.h>
#include <libsolutil/FixedHash.h>

#include <limits>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::langutil;
using namespace solidity::util;

using TypedValue = ConstantEvaluator::TypedValue;

namespace
{

/// Check whether (_base ** _exp) fits into 4096 bits.
bool fitsPrecisionExp(bigint const& _base, bigint const& _exp)
{
	if (_base == 0)
		return true;

	solAssert(_base > 0, "");

	std::size_t const bitsMax = 4096;

	std::size_t mostSignificantBaseBit = static_cast<std::size_t>(boost::multiprecision::msb(_base));
	if (mostSignificantBaseBit == 0) // _base == 1
		return true;
	if (mostSignificantBaseBit > bitsMax) // _base >= 2 ^ 4096
		return false;

	bigint bitsNeeded = _exp * (mostSignificantBaseBit + 1);

	return bitsNeeded <= bitsMax;
}

/// Checks whether _mantissa * (2 ** _expBase2) fits into 4096 bits.
bool fitsPrecisionBase2(bigint const& _mantissa, uint32_t _expBase2)
{
	return fitsPrecisionBaseX(_mantissa, 1.0, _expBase2);
}

}

std::optional<rational> ConstantEvaluator::evaluateBinaryOperator(Token _operator, rational const& _left, rational const& _right)
{
	bool fractional = _left.denominator() != 1 || _right.denominator() != 1;
	switch (_operator)
	{
	//bit operations will only be enabled for integers and fixed types that resemble integers
	case Token::BitOr:
		if (fractional)
			return std::nullopt;
		else
			return _left.numerator() | _right.numerator();
	case Token::BitXor:
		if (fractional)
			return std::nullopt;
		else
			return _left.numerator() ^ _right.numerator();
	case Token::BitAnd:
		if (fractional)
			return std::nullopt;
		else
			return _left.numerator() & _right.numerator();
	case Token::Add: return _left + _right;
	case Token::Sub: return _left - _right;
	case Token::Mul: return _left * _right;
	case Token::Div:
		if (_right == rational(0))
			return std::nullopt;
		else
			return _left / _right;
	case Token::Mod:
		if (_right == rational(0))
			return std::nullopt;
		else if (fractional)
		{
			rational tempValue = _left / _right;
			return _left - (tempValue.numerator() / tempValue.denominator()) * _right;
		}
		else
			return _left.numerator() % _right.numerator();
		break;
	case Token::Exp:
	{
		if (_right.denominator() != 1)
			return std::nullopt;
		bigint const& exp = _right.numerator();

		// x ** 0 = 1
		// for 0, 1 and -1 the size of the exponent doesn't have to be restricted
		if (exp == 0)
			return 1;
		else if (_left == 0 || _left == 1)
			return _left;
		else if (_left == -1)
		{
			bigint isOdd = abs(exp) & bigint(1);
			return 1 - 2 * isOdd.convert_to<int>();
		}
		else
		{
			if (abs(exp) > std::numeric_limits<uint32_t>::max())
				return std::nullopt; // This will need too much memory to represent.

			uint32_t absExp = bigint(abs(exp)).convert_to<uint32_t>();

			if (!fitsPrecisionExp(abs(_left.numerator()), absExp) || !fitsPrecisionExp(abs(_left.denominator()), absExp))
				return std::nullopt;

			static auto const optimizedPow = [](bigint const& _base, uint32_t _exponent) -> bigint {
				if (_base == 1)
					return 1;
				else if (_base == -1)
					return 1 - 2 * static_cast<int>(_exponent & 1);
				else
					return boost::multiprecision::pow(_base, _exponent);
			};

			bigint numerator = optimizedPow(_left.numerator(), absExp);
			bigint denominator = optimizedPow(_left.denominator(), absExp);

			if (exp >= 0)
				return makeRational(numerator, denominator);
			else
				// invert
				return makeRational(denominator, numerator);
		}
		break;
	}
	case Token::SHL:
	{
		if (fractional)
			return std::nullopt;
		else if (_right < 0)
			return std::nullopt;
		else if (_right > std::numeric_limits<uint32_t>::max())
			return std::nullopt;
		if (_left.numerator() == 0)
			return 0;
		else
		{
			uint32_t exponent = _right.numerator().convert_to<uint32_t>();
			if (!fitsPrecisionBase2(abs(_left.numerator()), exponent))
				return std::nullopt;
			return _left.numerator() * boost::multiprecision::pow(bigint(2), exponent);
		}
		break;
	}
	// NOTE: we're using >> (SAR) to denote right shifting. The type of the LValue
	//       determines the resulting type and the type of shift (SAR or SHR).
	case Token::SAR:
	{
		if (fractional)
			return std::nullopt;
		else if (_right < 0)
			return std::nullopt;
		else if (_right > std::numeric_limits<uint32_t>::max())
			return std::nullopt;
		if (_left.numerator() == 0)
			return 0;
		else
		{
			uint32_t exponent = _right.numerator().convert_to<uint32_t>();
			if (exponent > boost::multiprecision::msb(boost::multiprecision::abs(_left.numerator())))
				return _left.numerator() < 0 ? -1 : 0;
			else
			{
				if (_left.numerator() < 0)
					// Add 1 to the negative value before dividing to get a result that is strictly too large,
					// then subtract 1 afterwards to round towards negative infinity.
					// This is the same algorithm as used in ExpressionCompiler::appendShiftOperatorCode(...).
					// To see this note that for negative x, xor(x,all_ones) = (-x-1) and
					// therefore xor(div(xor(x,all_ones), exp(2, shift_amount)), all_ones) is
					// -(-x - 1) / 2^shift_amount - 1, which is the same as
					// (x + 1) / 2^shift_amount - 1.
					return rational((_left.numerator() + 1) / boost::multiprecision::pow(bigint(2), exponent) - bigint(1), 1);
				else
					return rational(_left.numerator() / boost::multiprecision::pow(bigint(2), exponent), 1);
			}
		}
		break;
	}
	default:
		return std::nullopt;
	}
}

std::optional<rational> ConstantEvaluator::evaluateUnaryOperator(Token _operator, rational const& _input)
{
	switch (_operator)
	{
	case Token::BitNot:
		if (_input.denominator() != 1)
			return std::nullopt;
		else
			return ~_input.numerator();
	case Token::Sub:
		return -_input;
	default:
		return std::nullopt;
	}
}

namespace
{

TypedValue convertType(rational const& _value, Type const& _type)
{
	if (_type.category() == Type::Category::RationalNumber)
		return TypedValue{TypeProvider::rationalNumber(_value), _value};
	else if (auto const* integerType = dynamic_cast<IntegerType const*>(&_type))
	{
		if (_value > integerType->maxValue() || _value < integerType->minValue())
			return TypedValue{};
		else
			return TypedValue{&_type, _value.numerator() / _value.denominator()};
	}
	else if (auto const* fixedBytesType = dynamic_cast<FixedBytesType const*>(&_type))
	{
		// Only bytes32 is supported for now.
		if (fixedBytesType->numBytes() != 32)
			return TypedValue{};

		if (
			_value.denominator() != 1 ||
			_value.numerator() < 0 ||
			_value.numerator() > TypeProvider::integer(fixedBytesType->numBytes() * 8, IntegerType::Modifier::Unsigned)->max()
		)
			return TypedValue{};

		u256 integerValue = u256(_value.numerator());
		// toBigEndian always returns 32 bytes, which is the only width supported.
		// If support for narrower widths is added, then unused high bytes need to be erased
		bytes bytesRepresentation = toBigEndian(integerValue);
		return TypedValue{&_type, bytesRepresentation};
	}

	return TypedValue{};
}

TypedValue convertType(std::string const& _value, Type const& _type)
{
	if (
		_type.category() == Type::Category::StringLiteral ||
		_type.category() == Type::Category::Array
	)
		return TypedValue{&_type, _value};
	else if (_type.category() == Type::Category::FixedBytes)
	{
		auto const& fixedBytes = dynamic_cast<FixedBytesType const&>(_type);
		// Only bytes32 is supported for now.
		if (fixedBytes.numBytes() != 32)
			return TypedValue{};

		if (_value.size() > fixedBytes.numBytes())
			return TypedValue{};

		// Right pad with zeros to the full width
		auto bytesValue = asBytes(_value);
		bytesValue.resize(fixedBytes.numBytes(), 0);
		return TypedValue{&_type, bytesValue};
	}

	return TypedValue{};
}

TypedValue convertType(bytes const& _value, Type const& _type)
{
	auto const* fixedBytes = dynamic_cast<FixedBytesType const*>(&_type);
	if (
		!fixedBytes ||
		_value.size() > fixedBytes->numBytes() ||
		fixedBytes->numBytes() != 32  // Supports only bytes32 for now
	)
		return TypedValue{};

	return TypedValue{&_type, _value};
}

TypedValue convertType(TypedValue const& _value, Type const& _type)
{
	return std::visit(util::GenericVisitor{
		[&](std::string const& value) {
			return convertType(value, _type);
		},
		[&](rational const& value) {
			return convertType(value, _type);
		},
		[&](bytes const& value) {
			return convertType(value, _type);
		},
		[&](std::monostate const&) {
			return TypedValue{};
		}
	}, _value.value());
}

TypedValue constantToTypedValue(Type const& _type)
{
	if (_type.category() == Type::Category::RationalNumber)
		return TypedValue{&_type, dynamic_cast<RationalNumberType const&>(_type).value()};
	else if (_type.category() == Type::Category::StringLiteral)
		return TypedValue{&_type, dynamic_cast<StringLiteralType const&>(_type).value()};

	return TypedValue{};
}

}

TypedValue ConstantEvaluator::evaluate(
	langutil::ErrorReporter& _errorReporter,
	Expression const& _expr
)
{
	return ConstantEvaluator{_errorReporter}.evaluate(_expr);
}

TypedValue ConstantEvaluator::tryEvaluate(Expression const& _expr)
{
	ErrorList errorList;
	ErrorReporter errorReporter(errorList);
	try
	{
		return ConstantEvaluator{errorReporter}.evaluate(_expr);
	}
	catch (FatalError const&)
	{
		return TypedValue{};
	}
}


TypedValue ConstantEvaluator::evaluate(ASTNode const& _node)
{
	if (!m_values.count(&_node))
	{
		if (auto const* varDecl = dynamic_cast<VariableDeclaration const*>(&_node))
		{
			solAssert(varDecl->isConstant(), "");
			// In some circumstances, we do not yet have a type for the variable.
			if (!varDecl->value() || !varDecl->type())
				m_values[&_node] = TypedValue{};
			else
			{
				m_depth++;
				if (m_depth > 32)
					m_errorReporter.fatalTypeError(
						5210_error,
						varDecl->location(),
						"Cyclic constant definition (or maximum recursion depth exhausted)."
					);
				m_values[&_node] = convertType(evaluate(*varDecl->value()), *varDecl->type());
				m_depth--;
			}
		}
		else if (auto const* expression = dynamic_cast<Expression const*>(&_node))
		{
			expression->accept(*this);
			if (!m_values.count(&_node))
				m_values[&_node] = TypedValue{};
		}
	}
	return m_values.at(&_node);
}

void ConstantEvaluator::endVisit(UnaryOperation const& _operation)
{
	TypedValue value = evaluate(_operation.subExpression());
	if (value.empty())
		return;

	Type const* resultType = value.type()->unaryOperatorResult(_operation.getOperator());
	if (!resultType)
		return;
	value = convertType(value, *resultType);
	if (!value.isRational())
		return;

	if (std::optional<rational> result = evaluateUnaryOperator(_operation.getOperator(), value.asRational()))
	{
		TypedValue convertedValue = convertType(*result, *resultType);
		if (!convertedValue.type())
			m_errorReporter.fatalTypeError(
				3667_error,
				_operation.location(),
				"Arithmetic error when computing constant value."
			);
		m_values[&_operation] = convertedValue;
	}
}

void ConstantEvaluator::endVisit(BinaryOperation const& _operation)
{
	TypedValue left = evaluate(_operation.leftExpression());
	TypedValue right = evaluate(_operation.rightExpression());
	if (!left.type() || !right.type())
		return;

	// If this is implemented in the future: Comparison operators have a "binaryOperatorResult"
	// that is non-bool, but the result has to be bool.
	if (TokenTraits::isCompareOp(_operation.getOperator()))
		return;

	Type const* resultType = left.type()->binaryOperatorResult(_operation.getOperator(), right.type());
	if (!resultType)
	{
		m_errorReporter.fatalTypeError(
			6020_error,
			_operation.location(),
			"Operator " +
			std::string(TokenTraits::toString(_operation.getOperator())) +
			" not compatible with types " +
			left.type()->toString() +
			" and " +
			right.type()->toString()
			);
		return;
	}

	left = convertType(left, *resultType);
	right = convertType(right, *resultType);
	if (
		!left.isRational() ||
		!right.isRational()
	)
		return;

	if (std::optional<rational> value = evaluateBinaryOperator(
		_operation.getOperator(),
		left.asRational(),
		right.asRational()
	))
	{
		TypedValue convertedValue = convertType(*value, *resultType);
		if (!convertedValue.type())
			m_errorReporter.fatalTypeError(
				2643_error,
				_operation.location(),
				"Arithmetic error when computing constant value."
			);
		m_values[&_operation] = convertedValue;
	}
}

void ConstantEvaluator::endVisit(Literal const& _literal)
{
	if (Type const* literalType = TypeProvider::forLiteral(_literal))
		m_values[&_literal] = constantToTypedValue(*literalType);
}

void ConstantEvaluator::endVisit(Identifier const& _identifier)
{
	VariableDeclaration const* variableDeclaration = dynamic_cast<VariableDeclaration const*>(_identifier.annotation().referencedDeclaration);
	if (variableDeclaration && variableDeclaration->isConstant())
		m_values[&_identifier] = evaluate(*variableDeclaration);
}

void ConstantEvaluator::endVisit(TupleExpression const& _tuple)
{
	if (!_tuple.isInlineArray() && _tuple.components().size() == 1)
		m_values[&_tuple] = evaluate(*_tuple.components().front());
}

void ConstantEvaluator::endVisit(FunctionCall const& _functionCall)
{
	auto const* elementaryTypeNameExpression = dynamic_cast<ElementaryTypeNameExpression const*>(&_functionCall.expression());
	if (elementaryTypeNameExpression)
	{
		// Type checking might not have been performed yet. This is the same that is done in that step.
		auto const* expressionTypeType = TypeProvider::typeType(TypeProvider::fromElementaryTypeName(
			elementaryTypeNameExpression->type().typeName(),
			elementaryTypeNameExpression->type().stateMutability()
		));
		solAssert(expressionTypeType);
		solAssert(expressionTypeType->actualType());

		// For now, only conversion target supported: uint256
		auto const* integerResultType = dynamic_cast<IntegerType const*>(expressionTypeType->actualType());
		if (!integerResultType || integerResultType != TypeProvider::uint256())
			return;

		if (_functionCall.arguments().size() != 1 || !_functionCall.names().empty())
			return;

		TypedValue valueToConvert = evaluate(*_functionCall.arguments().front());
		if (!valueToConvert.type() || !valueToConvert.type()->isExplicitlyConvertibleTo(*integerResultType))
			return;

		u256 convertedValue = 0;
		if (
			valueToConvert.type()->category() == Type::Category::Integer ||
			valueToConvert.type()->category() == Type::Category::RationalNumber
		)
		{
			solAssert(valueToConvert.isRational());
			auto const& rationalValue = valueToConvert.asRational();
			solAssert(rationalValue.denominator() == 1);

			convertedValue = rationalValue >= rational(0) ?
				u256(rationalValue.numerator()) :
				s2u(s256(rationalValue.numerator()));
		}
		else if (valueToConvert.type()->category() == Type::Category::FixedBytes)
		{
			solAssert(valueToConvert.isBytes());
			auto const& bytesValue = valueToConvert.asBytes();
			auto const& fixedBytesType = static_cast<FixedBytesType const&>(*valueToConvert.type());
			solAssert(size_t(integerResultType->numBits()) == fixedBytesType.numBytes() * 8);

			// FixedBytes is left-aligned.
			for (auto byte: bytesValue)
				convertedValue = (convertedValue << 8) | u256(byte);

			// fill with remaining zero bytes
			auto remainingBytes = size_t(fixedBytesType.numBytes()) - bytesValue.size();
			convertedValue <<= 8 * remainingBytes;
		}
		else // Type is explicitly convertible but not evaluated at comptime
			return;

		m_values[&_functionCall] = TypedValue{integerResultType, rational(convertedValue)};
		return;
	}

	auto const* builtinFunction = dynamic_cast<MagicVariableDeclaration const*>(ASTNode::referencedDeclaration(_functionCall.expression()));
	if (!builtinFunction)
		return;

	auto const* functionType = builtinFunction->functionType(true);
	solAssert(functionType);
	switch (functionType->kind())
	{
		case FunctionType::Kind::ERC7201:
		{
			solAssert(_functionCall.arguments().size() == 1);
			auto stringArg = evaluate(*(_functionCall.arguments()[0].get()));
			if (!stringArg.isString())
				return;

			h256 innerKeccak = keccak256(stringArg.asString());
			h256 outerKeccak = keccak256(h256(u256(innerKeccak) - 1));
			outerKeccak.data()[31] = 0;
			u256 slot = outerKeccak;
			solAssert(functionType->returnParameterTypes().size() == 1);
			m_values[&_functionCall] = TypedValue{functionType->returnParameterTypes()[0], rational{slot}};
			break;
		}
		case FunctionType::Kind::KECCAK256:
		{
			if (_functionCall.arguments().size() != 1)
				return;
			auto argValue = evaluate(*_functionCall.arguments()[0]);
			if (!argValue.isString())
				return;

			h256 hash = keccak256(argValue.asString());
			solAssert(functionType->returnParameterTypes().size() == 1);
			solAssert(functionType->returnParameterTypes()[0] == TypeProvider::fixedBytes(32));
			m_values[&_functionCall] = TypedValue{functionType->returnParameterTypes()[0], hash.asBytes()};
			break;
		}
		default:
			break;
	}
}

TypedValue::TypedValue(Type const* _type, TypedValue::Value _value)
{
	std::visit(util::GenericVisitor{
		[&](std::string const&) {
			solAssert(dynamic_cast<StringLiteralType const*>(_type) || dynamic_cast<ArrayType const*>(_type));
		},
		[&](rational const&) {
			solAssert(dynamic_cast<RationalNumberType const*>(_type) || dynamic_cast<IntegerType const*>(_type));
		},
		[&](bytes const&) {
			solAssert(dynamic_cast<FixedBytesType const*>(_type));
		},
		[&](std::monostate const&) {
			solAssert(!_type);
		}
	}, _value);

	m_type = _type;
	m_value = std::move(_value);
}

std::string const& TypedValue::asString() const
{
	auto const* stringValue = std::get_if<std::string>(&m_value);
	solAssert(stringValue);
	return *stringValue;
}

rational const& TypedValue::asRational() const
{
	auto const* rationalValue = std::get_if<rational>(&m_value);
	solAssert(rationalValue);
	return *rationalValue;
}

bytes const& TypedValue::asBytes() const
{
	auto const* bytesValue = std::get_if<bytes>(&m_value);
	solAssert(bytesValue);
	return *bytesValue;
}
