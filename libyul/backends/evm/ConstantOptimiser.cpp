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
 * Optimisation stage that replaces constants by expressions that compute them.
 */

#include <libyul/backends/evm/ConstantOptimiser.h>

#include <libyul/optimiser/ASTCopier.h>
#include <libyul/backends/evm/EVMMetrics.h>
#include <libyul/AST.h>
#include <libyul/Utilities.h>

#include <libsolutil/CommonData.h>

#include <variant>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::util;

using Representation = ConstantOptimiser::Representation;

namespace
{
struct MiniEVMInterpreter
{
	explicit MiniEVMInterpreter(EVMDialect const& _dialect): m_dialect(_dialect) {}

	u256 eval(Expression const& _expr)
	{
		return std::visit(*this, _expr);
	}

	u256 eval(evmasm::Instruction _instr, std::vector<Expression> const& _arguments)
	{
		std::vector<u256> args;
		for (auto const& arg: _arguments)
			args.emplace_back(eval(arg));
		switch (_instr)
		{
		case evmasm::Instruction::ADD:
			return args.at(0) + args.at(1);
		case evmasm::Instruction::SUB:
			return args.at(0) - args.at(1);
		case evmasm::Instruction::MUL:
			return args.at(0) * args.at(1);
		case evmasm::Instruction::EXP:
			return exp256(args.at(0), args.at(1));
		case evmasm::Instruction::SHL:
			return args.at(0) > 255 ? 0 : (args.at(1) << unsigned(args.at(0)));
		case evmasm::Instruction::SHR:
			return args.at(1) >> unsigned(args.at(0));
		case evmasm::Instruction::NOT:
			return ~args.at(0);
		default:
			yulAssert(false, "Invalid operation generated in constant optimizer.");
		}
		return 0;
	}

	u256 operator()(FunctionCall const& _funCall)
	{
		BuiltinFunctionForEVM const* builtin = resolveBuiltinFunctionForEVM(_funCall.functionName, m_dialect);
		yulAssert(builtin, "Expected builtin function.");
		yulAssert(builtin->instruction, "Expected EVM instruction.");
		return eval(*builtin->instruction, _funCall.arguments);
	}
	u256 operator()(Literal const& _literal)
	{
		return _literal.value.value();
	}
	u256 operator()(Identifier const&) { yulAssert(false, ""); }

	EVMDialect const& m_dialect;
};
}

void ConstantOptimiser::visit(Expression& _e)
{
	if (std::holds_alternative<Literal>(_e))
	{
		Literal const& literal = std::get<Literal>(_e);
		if (literal.kind != LiteralKind::Number)
			return;

		if (
			Expression const* repr =
				RepresentationFinder(m_dialect, m_meter, debugDataOf(_e), m_cache)
				.tryFindRepresentation(literal.value.value())
		)
			_e = ASTCopier{}.translate(*repr);
	}
	else
		ASTModifier::visit(_e);
}

Expression const* RepresentationFinder::tryFindRepresentation(u256 const& _value)
{
	if (_value < 0x10000)
		return nullptr;

	Representation const& repr = findRepresentation(_value);
	if (std::holds_alternative<Literal>(*repr.expression))
		return nullptr;
	else
		return repr.expression.get();
}

Representation const& RepresentationFinder::findRepresentation(u256 const& _value)
{
	if (m_cache.count(_value))
		return m_cache.at(_value);

	yulAssert(m_dialect.auxiliaryBuiltinHandles().not_);
	yulAssert(m_dialect.auxiliaryBuiltinHandles().exp);
	yulAssert(m_dialect.auxiliaryBuiltinHandles().mul);
	yulAssert(m_dialect.auxiliaryBuiltinHandles().add);
	yulAssert(m_dialect.auxiliaryBuiltinHandles().sub);

	auto const& auxHandles = m_dialect.auxiliaryBuiltinHandles();

	Representation routine = represent(_value);

	// A constant having a single contiguous run of ones, common in masking,
	// can be efficiently created by first filling with 1's, then shifting
	// left and/or right as needed to make the sides full of zeros.
	//
	//                                  onesEnd     onesStart
	//                                      v           v
	// 0x000000000000000000000000000000000000ffffffffffff0000000000000000
	//
	// If the value is all zeros, both onesEnd and onesStart will be 256.

	// Find the index of the lowest one 1 bit
	unsigned onesStart;
	for (onesStart = 0; onesStart < 256; ++onesStart)
		if (((_value >> onesStart) & 1) != 0)
			break;

	// Find the index after the highest one 1 bit in the run of 1's.
	unsigned onesEnd;
	for (onesEnd = onesStart; onesEnd < 256; ++onesEnd)
		if (((_value >> onesEnd) & 1) == 0)
			break;

	// Check that there are no ones after onesEnd
	bool const isOnlyContiguousOnes = (onesEnd == 256 || (_value >> onesEnd) == 0);

	bool const worthTrying =
		_value != 0 && // defensive check
		m_dialect.evmVersion().hasBitwiseShifting() &&
		onesEnd - onesStart > 32 && // push would be more efficient otherwise
		(onesEnd < 256 || onesStart > 16); // negation more effective for 0xFF..FFFF00

	if (isOnlyContiguousOnes && worthTrying)
	{
		// Build up the code, starting with a negated 0 to produce all ones.
		// 0x00 ! ==
		// 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
		Representation newRoutine = represent(*auxHandles.not_, represent(0));

		// Shift right as needed to create the correct number of 1 bits.
		// 0x0000000000000000000000000000000000000000000000000000ffffffffffff
		// If left aligned, we only need a left shift, and skip the right shift.
		if (onesEnd != 256)
			newRoutine = represent(*auxHandles.shr, represent(256 - (onesEnd - onesStart)), newRoutine);

		// If needed, shift left to position the bits in the correct place
		// or to setup a left aligned mask
		// 0x000000000000000000000000000000000000ffffffffffff0000000000000000
		if (onesStart > 0)
			newRoutine = represent(*auxHandles.shl, represent(onesStart), newRoutine);
		routine = min(std::move(routine), std::move(newRoutine));
	}


	if (numberEncodingSize(~_value) < numberEncodingSize(_value))
		// Negated is shorter to represent
		routine = min(std::move(routine), represent(*auxHandles.not_, findRepresentation(~_value)));

	// Decompose value into a * 2**k + b where abs(b) << 2**k
	for (unsigned bits = 255; bits > 8 && m_maxSteps > 0; --bits)
	{
		unsigned gapDetector = unsigned((_value >> (bits - 8)) & 0x1ff);
		if (gapDetector != 0xff && gapDetector != 0x100)
			continue;

		u256 powerOfTwo = u256(1) << bits;
		u256 upperPart = _value >> bits;
		bigint lowerPart = _value & (powerOfTwo - 1);
		if ((powerOfTwo - lowerPart) < lowerPart)
		{
			lowerPart = lowerPart - powerOfTwo; // make it negative
			upperPart++;
		}
		if (upperPart == 0)
			continue;
		if (abs(lowerPart) >= (powerOfTwo >> 8))
			continue;
		Representation newRoutine;
		if (m_dialect.evmVersion().hasBitwiseShifting())
			newRoutine = represent(*auxHandles.shl, represent(bits), findRepresentation(upperPart));
		else
		{
			newRoutine = represent(*auxHandles.exp, represent(2), represent(bits));
			if (upperPart != 1)
				newRoutine = represent(*auxHandles.mul, findRepresentation(upperPart), newRoutine);
		}

		if (newRoutine.cost >= routine.cost)
			continue;

		if (lowerPart > 0)
			newRoutine = represent(*auxHandles.add, newRoutine, findRepresentation(u256(abs(lowerPart))));
		else if (lowerPart < 0)
			newRoutine = represent(*auxHandles.sub, newRoutine, findRepresentation(u256(abs(lowerPart))));

		if (m_maxSteps > 0)
			m_maxSteps--;
		routine = min(std::move(routine), std::move(newRoutine));
	}
	yulAssert(MiniEVMInterpreter{m_dialect}.eval(*routine.expression) == _value, "Invalid expression generated.");
	return m_cache[_value] = std::move(routine);
}

Representation RepresentationFinder::represent(u256 const& _value) const
{
	Representation repr;
	repr.expression = std::make_unique<Expression>(Literal{m_debugData, LiteralKind::Number, LiteralValue{_value, formatNumber(_value)}});
	repr.cost = m_meter.costs(*repr.expression);
	return repr;
}

Representation RepresentationFinder::represent(
	BuiltinHandle const& _instruction,
	Representation const& _argument
) const
{
	Representation repr;
	repr.expression = std::make_unique<Expression>(FunctionCall{
		m_debugData,
		BuiltinName{m_debugData, _instruction},
		{ASTCopier{}.translate(*_argument.expression)}
	});
	repr.cost = _argument.cost + m_meter.instructionCosts(*m_dialect.builtin(_instruction).instruction);
	return repr;
}

Representation RepresentationFinder::represent(
	BuiltinHandle const& _instruction,
	Representation const& _arg1,
	Representation const& _arg2
) const
{
	Representation repr;
	repr.expression = std::make_unique<Expression>(FunctionCall{
		m_debugData,
		BuiltinName{m_debugData, _instruction},
		{ASTCopier{}.translate(*_arg1.expression), ASTCopier{}.translate(*_arg2.expression)}
	});
	repr.cost = m_meter.instructionCosts(*m_dialect.builtin(_instruction).instruction) + _arg1.cost + _arg2.cost;
	return repr;
}

Representation RepresentationFinder::min(Representation _a, Representation _b)
{
	if (_a.cost <= _b.cost)
		return _a;
	else
		return _b;
}
