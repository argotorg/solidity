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

		yulAssert(m_dialect.auxiliaryBuiltinHandles().not_);

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
	if (_value < 0x100000000)
		return nullptr;

	Representation const& repr = findRepresentation(_value);
	if (std::holds_alternative<Literal>(*repr.expression))
		return nullptr;
	else
		return repr.expression.get();
}

Representation const& RepresentationFinder::findRepresentation(u256 const& _value)
{
	// since findRepresentation is called recursively, the small value check must be done here
	if (_value < 0x100000000)
		return m_cache[_value] = represent(_value);

	if (m_cache.count(_value))
		return m_cache.at(_value);

	auto const& auxHandles = m_dialect.auxiliaryBuiltinHandles();

	Representation routine = represent(_value);

	if (m_dialect.evmVersion().hasBitwiseShifting())
	{
		// try left shift for patterns like xxxx0000
		unsigned zerosAtEnd = 0;
		while (((_value >> zerosAtEnd) & 1) == 0 && zerosAtEnd < 256)
			++zerosAtEnd;
		if (zerosAtEnd > 0)
		{
			Representation newRoutine = represent(*auxHandles.shl, represent(zerosAtEnd), findRepresentation(_value >> zerosAtEnd));
			routine = min(std::move(routine), std::move(newRoutine));
		}
		// try notZeroShift for patterns 0000....0011111
		unsigned onesAtEnd = 0;
		while (((_value >> onesAtEnd) & 1) == 1 && onesAtEnd < 256)
			++onesAtEnd;

		if ((_value >> onesAtEnd) == 0) // implicitly checks that onesAtEnd > 0
		{
			Representation newRoutine = represent(*auxHandles.shr, represent(256 - onesAtEnd), represent(*auxHandles.not_, represent(0)));
			routine = min(std::move(routine), std::move(newRoutine));
		}
	}

	// try NOT
	if (numberEncodingSize(~_value) < numberEncodingSize(_value))
		routine = min(std::move(routine), represent(*auxHandles.not_, findRepresentation(~_value)));

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
