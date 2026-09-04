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

#include <test/fuzztest/libyul/YulProgramGenerator.h>

#include <libyul/AST.h>
#include <libyul/Dialect.h>
#include <libyul/Exceptions.h>
#include <libyul/backends/evm/EVMDialect.h>

#include <liblangutil/DebugData.h>
#include <liblangutil/EVMVersion.h>

#include <libsolutil/Numeric.h>
#include <libsolutil/Visitor.h>

#include <array>
#include <memory>
#include <set>
#include <string>
#include <string_view>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::test::gen;

namespace
{

// Op tables. Indices in the representation are resolved modulo the table size.
constexpr std::array<std::string_view, 16> pureOps{
	"add", "sub", "mul", "div", "mod", "lt", "gt", "eq", "and", "or", "xor", "shl", "shr", "iszero", "not", "exp"
};
constexpr std::array<std::string_view, 5> readOps{"mload", "sload", "calldataload", "msize", "calldatasize"};
constexpr std::array<std::string_view, 4> writeOps{"mstore", "sstore", "mstore8", "pop"};
constexpr std::array<std::string_view, 4> termOps{"stop", "invalid", "revert", "return"};

/// Hidden per-loop iteration bound. Every `for` gets a counter in its pre block and `lt(counter, loopBound)`
/// conjoined to its condition, so lifted programs terminate without relying on the interpreter step limit.
constexpr unsigned loopBound = 5;

constexpr std::uint8_t maxParams = 4;   // numParams % maxParams
constexpr std::uint8_t maxReturns = 3;  // numReturns % maxReturns

class Lifter
{
public:
	explicit Lifter(Dialect const& _dialect): m_dialect(_dialect) {}

	yul::AST lift(Program const& _program);

private:
	struct FunctionSig
	{
		YulName name;
		std::size_t numParams;
		std::size_t numReturns;
	};

	struct Context
	{
		bool inFunction;
		bool inLoopBody;
		/// Functions `f0 .. f(callableFunctions-1)` may be called. Inside function `i` this is `i`, so the
		/// call graph is a DAG and every lifted program terminates.
		std::size_t callableFunctions;
	};

	static langutil::DebugData::ConstPtr debug() { return langutil::DebugData::create(); }
	YulName freshVariable() { return YulName("v" + std::to_string(m_variableCounter++)); }

	BuiltinHandle builtinHandle(std::string_view _name) const
	{
		std::optional<BuiltinHandle> const handle = m_dialect.findBuiltin(_name);
		yulAssert(handle.has_value(), "Dialect lacks builtin " + std::string(_name));
		return *handle;
	}
	std::size_t arityOf(std::string_view _name) const { return m_dialect.builtin(builtinHandle(_name)).numParameters; }

	static Expression literal(u256 const& _value)
	{
		return Literal{debug(), LiteralKind::Number, LiteralValue{_value}};
	}
	static Expression identifier(YulName const& _name) { return Identifier{debug(), _name}; }
	Expression builtinCall(std::string_view _name, std::vector<Expression> _arguments) const
	{
		BuiltinHandle const handle = builtinHandle(_name);
		yulAssert(m_dialect.builtin(handle).numParameters == _arguments.size(), "Builtin arity mismatch in lift.");
		return FunctionCall{debug(), FunctionName{BuiltinName{debug(), handle}}, std::move(_arguments)};
	}
	Expression userCall(FunctionSig const& _sig, std::vector<Expr> const& _args, Context const& _ctx)
	{
		return FunctionCall{debug(), FunctionName{Identifier{debug(), _sig.name}}, liftArgs(_args, _sig.numParams, _ctx)};
	}

	/// Resolves a variable reference per the `Index` convention; nullopt in an empty scope.
	std::optional<YulName> resolveVariable(Index _index) const
	{
		if (m_scope.empty())
			return std::nullopt;
		bool const preferOuter = (_index & 0x80) != 0;
		std::size_t const position = _index & 0x7f;
		std::size_t const outerCount = m_blockStarts.empty() ? 0 : m_blockStarts.back();
		if (preferOuter && outerCount > 0)
			return m_scope[position % outerCount];
		return m_scope[position % m_scope.size()];
	}

	std::vector<Expression> liftArgs(std::vector<Expr> const& _args, std::size_t _arity, Context const& _ctx);
	Expression liftExpr(Expr const& _expr, Context const& _ctx);
	yul::Block liftBlock(test::gen::Block const& _block, Context const& _ctx);
	void liftStatement(Stmt const& _stmt, Context const& _ctx, std::vector<Statement>& _out);
	void liftCompound(CompoundStmt const& _stmt, Context const& _ctx, std::vector<Statement>& _out);
	void liftLetCall(LetCallStmt const& _stmt, Context const& _ctx, std::vector<Statement>& _out);
	void liftFor(ForStmt const& _stmt, Context const& _ctx, std::vector<Statement>& _out);

	Dialect const& m_dialect;
	std::vector<FunctionSig> m_functions;
	/// Variables visible at the current point, in declaration order.
	std::vector<YulName> m_scope;
	/// `m_scope.size()` at the start of each enclosing block; the top says which variables are "outer".
	std::vector<std::size_t> m_blockStarts;
	std::size_t m_variableCounter = 0;
};

std::vector<Expression> Lifter::liftArgs(std::vector<Expr> const& _args, std::size_t const _arity, Context const& _ctx)
{
	std::vector<Expression> out;
	for (std::size_t i = 0; i < _arity; ++i)
		if (i < _args.size())
			out.push_back(liftExpr(_args[i], _ctx));
		else
			// Pad with an in-scope variable (or a literal if the scope is empty) rather than a constant,
			// so padded operands still create uses.
			out.push_back(liftExpr(Expr{VarExpr{static_cast<Index>(i)}}, _ctx));
	return out;
}

Expression Lifter::liftExpr(Expr const& _expr, Context const& _ctx)
{
	return std::visit(util::GenericVisitor{
		[&](LiteralExpr const& _e) -> Expression { return literal(u256(_e.value)); },
		[&](VarExpr const& _e) -> Expression
		{
			if (std::optional<YulName> const name = resolveVariable(_e.index))
				return identifier(*name);
			return literal(u256(_e.index & 0x7f));
		},
		[&](PureCallExpr const& _e) -> Expression
		{
			std::string_view const name = pureOps[_e.op % pureOps.size()];
			return builtinCall(name, liftArgs(_e.args, arityOf(name), _ctx));
		},
		[&](ReadCallExpr const& _e) -> Expression
		{
			std::string_view const name = readOps[_e.op % readOps.size()];
			return builtinCall(name, liftArgs(_e.args, arityOf(name), _ctx));
		},
		[&](UserCallExpr const& _e) -> Expression
		{
			std::vector<std::size_t> candidates;
			for (std::size_t i = 0; i < _ctx.callableFunctions; ++i)
				if (m_functions[i].numReturns == 1)
					candidates.push_back(i);
			if (candidates.empty())
				return _e.args.empty()
					? liftExpr(Expr{VarExpr{_e.function}}, _ctx)
					: liftExpr(_e.args.front(), _ctx);
			return userCall(m_functions[candidates[_e.function % candidates.size()]], _e.args, _ctx);
		}
	}, _expr.node);
}

yul::Block Lifter::liftBlock(test::gen::Block const& _block, Context const& _ctx)
{
	std::size_t const scopeMark = m_scope.size();
	m_blockStarts.push_back(scopeMark);
	yul::Block out{debug(), {}};
	for (Stmt const& stmt: _block.statements)
		liftStatement(stmt, _ctx, out.statements);
	m_blockStarts.pop_back();
	m_scope.resize(scopeMark);
	return out;
}

void Lifter::liftLetCall(LetCallStmt const& _stmt, Context const& _ctx, std::vector<Statement>& _out)
{
	if (_ctx.callableFunctions == 0)
	{
		// Nothing to call: degrade to an uninitialised declaration so the statement still declares something.
		YulName const name = freshVariable();
		_out.push_back(VariableDeclaration{debug(), {NameWithDebugData{debug(), name}}, nullptr});
		m_scope.push_back(name);
		return;
	}
	FunctionSig const& sig = m_functions[_stmt.function % _ctx.callableFunctions];
	Expression call = userCall(sig, _stmt.args, _ctx);
	if (sig.numReturns == 0)
	{
		_out.push_back(ExpressionStatement{debug(), std::move(call)});
		return;
	}
	NameWithDebugDataList names;
	for (std::size_t i = 0; i < sig.numReturns; ++i)
		names.push_back(NameWithDebugData{debug(), freshVariable()});
	_out.push_back(VariableDeclaration{debug(), names, std::make_unique<Expression>(std::move(call))});
	for (NameWithDebugData const& name: names)
		m_scope.push_back(name.name);
}

void Lifter::liftStatement(Stmt const& _stmt, Context const& _ctx, std::vector<Statement>& _out)
{
	std::visit(util::GenericVisitor{
		[&](LetStmt const& _s)
		{
			YulName const name = freshVariable();
			std::unique_ptr<Expression> value;
			if (_s.value)
				value = std::make_unique<Expression>(liftExpr(*_s.value, _ctx));
			_out.push_back(VariableDeclaration{debug(), {NameWithDebugData{debug(), name}}, std::move(value)});
			m_scope.push_back(name);
		},
		[&](LetCallStmt const& _s) { liftLetCall(_s, _ctx, _out); },
		[&](AssignStmt const& _s)
		{
			Expression value = liftExpr(_s.value, _ctx);
			if (std::optional<YulName> const target = resolveVariable(_s.target))
				_out.push_back(Assignment{
					debug(),
					{Identifier{debug(), *target}},
					std::make_unique<Expression>(std::move(value))
				});
			else
				_out.push_back(ExpressionStatement{debug(), builtinCall("pop", {std::move(value)})});
		},
		[&](AssignCallStmt const& _s)
		{
			if (_ctx.callableFunctions == 0)
				return liftLetCall(LetCallStmt{_s.function, _s.args}, _ctx, _out);
			FunctionSig const& sig = m_functions[_s.function % _ctx.callableFunctions];
			if (sig.numReturns == 0 || m_scope.size() < sig.numReturns)
				// Zero returns: expression statement. Too few distinct targets: declare fresh ones instead.
				return liftLetCall(LetCallStmt{_s.function, _s.args}, _ctx, _out);
			std::vector<Identifier> targets;
			for (std::size_t i = 0; i < sig.numReturns; ++i)
				targets.push_back(Identifier{debug(), m_scope[(_s.firstTarget + i) % m_scope.size()]});
			_out.push_back(Assignment{
				debug(),
				std::move(targets),
				std::make_unique<Expression>(userCall(sig, _s.args, _ctx))
			});
		},
		[&](WriteStmt const& _s)
		{
			std::string_view const name = writeOps[_s.op % writeOps.size()];
			_out.push_back(ExpressionStatement{debug(), builtinCall(name, liftArgs(_s.args, arityOf(name), _ctx))});
		},
		[&](TermStmt const& _s)
		{
			std::string_view const name = termOps[_s.op % termOps.size()];
			_out.push_back(ExpressionStatement{debug(), builtinCall(name, liftArgs(_s.args, arityOf(name), _ctx))});
		},
		[&](BreakStmt const&)
		{
			if (_ctx.inLoopBody)
				_out.push_back(Break{debug()});
		},
		[&](ContinueStmt const&)
		{
			if (_ctx.inLoopBody)
				_out.push_back(Continue{debug()});
		},
		[&](LeaveStmt const&)
		{
			if (_ctx.inFunction)
				_out.push_back(Leave{debug()});
		},
		[&](CondExitStmt const& _s)
		{
			yul::Block body{debug(), {}};
			switch (_s.kind % 3)
			{
			case 0:
				if (_ctx.inLoopBody)
					body.statements.push_back(Break{debug()});
				break;
			case 1:
				if (_ctx.inLoopBody)
					body.statements.push_back(Continue{debug()});
				break;
			default:
				if (_ctx.inFunction)
					body.statements.push_back(Leave{debug()});
				break;
			}
			_out.push_back(If{debug(), std::make_unique<Expression>(liftExpr(_s.condition, _ctx)), std::move(body)});
		},
		[&](ForStmt const& _s) { liftFor(_s, _ctx, _out); },
		[&](CompoundStmt const& _s) { liftCompound(_s, _ctx, _out); }
	}, _stmt.node);
}

void Lifter::liftFor(ForStmt const& _s, Context const& _ctx, std::vector<Statement>& _out)
{
	// Variables declared in `pre` stay visible in condition, post and body.
	std::size_t const scopeMark = m_scope.size();
	Context outsideBody = _ctx;
	outsideBody.inLoopBody = false;  // break/continue are not allowed in pre/post

	yul::Block pre{debug(), {}};
	for (Stmt const& stmt: _s.pre.statements)
		liftStatement(stmt, outsideBody, pre.statements);
	YulName const counter = freshVariable();  // hidden: not pushed to m_scope
	pre.statements.push_back(VariableDeclaration{
		debug(), {NameWithDebugData{debug(), counter}}, std::make_unique<Expression>(literal(0))
	});

	Expression condition = builtinCall("and", {
		builtinCall("iszero", {builtinCall("iszero", {liftExpr(_s.condition, _ctx)})}),
		builtinCall("lt", {identifier(counter), literal(loopBound)})
	});

	yul::Block post = liftBlock(_s.post, outsideBody);
	post.statements.push_back(Assignment{
		debug(),
		{Identifier{debug(), counter}},
		std::make_unique<Expression>(builtinCall("add", {identifier(counter), literal(1)}))
	});

	Context bodyContext = _ctx;
	bodyContext.inLoopBody = true;
	yul::Block body = liftBlock(_s.body, bodyContext);

	m_scope.resize(scopeMark);
	_out.push_back(ForLoop{
		debug(),
		std::move(pre),
		std::make_unique<Expression>(std::move(condition)),
		std::move(post),
		std::move(body)
	});
}

void Lifter::liftCompound(CompoundStmt const& _stmt, Context const& _ctx, std::vector<Statement>& _out)
{
	std::visit(util::GenericVisitor{
		[&](IfStmt const& _s)
		{
			_out.push_back(If{
				debug(),
				std::make_unique<Expression>(liftExpr(_s.condition, _ctx)),
				liftBlock(_s.body, _ctx)
			});
		},
		[&](SwitchStmt const& _s)
		{
			Expression expression = liftExpr(_s.expression, _ctx);
			std::vector<yul::Case> cases;
			std::set<std::uint8_t> seen;
			for (test::gen::Case const& c: _s.cases)
				if (seen.insert(c.value).second)
					cases.push_back(yul::Case{
						debug(),
						std::make_unique<Literal>(Literal{debug(), LiteralKind::Number, LiteralValue{u256(c.value)}}),
						liftBlock(c.body, _ctx)
					});
			if (cases.empty())
				cases.push_back(yul::Case{
					debug(),
					std::make_unique<Literal>(Literal{debug(), LiteralKind::Number, LiteralValue{u256(0)}}),
					yul::Block{debug(), {}}
				});
			if (_s.defaultCase)
				cases.push_back(yul::Case{debug(), nullptr, liftBlock(*_s.defaultCase, _ctx)});
			_out.push_back(Switch{debug(), std::make_unique<Expression>(std::move(expression)), std::move(cases)});
		},
		[&](BlockStmt const& _s) { _out.push_back(liftBlock(_s.body, _ctx)); }
	}, _stmt.node);
}

yul::AST Lifter::lift(Program const& _program)
{
	m_functions.clear();
	m_scope.clear();
	m_variableCounter = 0;

	for (std::size_t i = 0; i < _program.functions.size(); ++i)
		m_functions.push_back(FunctionSig{
			YulName("f" + std::to_string(i)),
			static_cast<std::size_t>(_program.functions[i].numParams % maxParams),
			static_cast<std::size_t>(_program.functions[i].numReturns % maxReturns)
		});

	yul::Block root{debug(), {}};
	for (std::size_t i = 0; i < _program.functions.size(); ++i)
	{
		FunctionSig const& sig = m_functions[i];
		NameWithDebugDataList parameters;
		NameWithDebugDataList returnVariables;
		for (std::size_t j = 0; j < sig.numParams; ++j)
		{
			parameters.push_back(NameWithDebugData{debug(), freshVariable()});
			m_scope.push_back(parameters.back().name);
		}
		for (std::size_t j = 0; j < sig.numReturns; ++j)
		{
			returnVariables.push_back(NameWithDebugData{debug(), freshVariable()});
			m_scope.push_back(returnVariables.back().name);
		}
		Context const context{/*inFunction=*/true, /*inLoopBody=*/false, /*callableFunctions=*/i};
		yul::Block body = liftBlock(_program.functions[i].body, context);
		m_scope.clear();
		root.statements.push_back(FunctionDefinition{
			debug(), sig.name, std::move(parameters), std::move(returnVariables), std::move(body)
		});
	}

	Context const mainContext{/*inFunction=*/false, /*inLoopBody=*/false, /*callableFunctions=*/m_functions.size()};
	for (Stmt const& stmt: _program.main.statements)
		liftStatement(stmt, mainContext, root.statements);
	m_scope.clear();

	return yul::AST(m_dialect, std::move(root));
}

}

namespace solidity::yul::test::gen
{

fuzztest::Domain<Program> ProgramDomain()
{
	using namespace fuzztest;

	DomainBuilder builder;
	Domain<Expr> const expr = builder.Get<Expr>("expr");
	Domain<Block> const block = builder.Get<Block>("block");
	auto const index = Arbitrary<Index>();
	auto const byte = Arbitrary<std::uint8_t>();
	auto const exprs = [&](std::size_t _max) { return VectorOf(expr).WithMaxSize(_max); };

	// Expected number of child expressions per node is 0.6 < 1, so generation terminates.
	builder.Set<Expr>("expr", StructOf<Expr>(VariantOf<ExprNode>(
		StructOf<LiteralExpr>(byte),
		StructOf<VarExpr>(index),
		StructOf<PureCallExpr>(byte, exprs(2)),
		StructOf<ReadCallExpr>(byte, exprs(1)),
		StructOf<UserCallExpr>(index, exprs(3))
	)));

	// Twelve alternatives, at most four statements per block. A `for` carries three blocks and the compound
	// alternative up to four, so the expected number of nested statements per statement is about 0.6 < 1:
	// generation terminates while mutation can still grow programs.
	auto const stmt = StructOf<Stmt>(VariantOf<StmtNode>(
		StructOf<LetStmt>(OptionalOf(expr)),
		StructOf<LetCallStmt>(index, exprs(3)),
		StructOf<AssignStmt>(index, expr),
		StructOf<AssignCallStmt>(index, index, exprs(3)),
		StructOf<WriteStmt>(byte, exprs(2)),
		StructOf<TermStmt>(byte, exprs(2)),
		Just(BreakStmt{}),
		Just(ContinueStmt{}),
		Just(LeaveStmt{}),
		StructOf<CondExitStmt>(expr, byte),
		StructOf<ForStmt>(block, expr, block, block),
		StructOf<CompoundStmt>(VariantOf<CompoundNode>(
			StructOf<IfStmt>(expr, block),
			StructOf<SwitchStmt>(expr, VectorOf(StructOf<Case>(byte, block)).WithMaxSize(3), OptionalOf(block)),
			StructOf<BlockStmt>(block)
		))
	));
	builder.Set<Block>("block", StructOf<Block>(VectorOf(stmt).WithMaxSize(4)));

	Domain<Block> const blockDomain = std::move(builder).Finalize<Block>("block");
	return StructOf<Program>(
		VectorOf(StructOf<Function>(byte, byte, blockDomain)).WithMaxSize(3),
		blockDomain
	);
}

yul::AST lift(Program const& _program, Dialect const& _dialect)
{
	return Lifter{_dialect}.lift(_program);
}

Dialect const& defaultDialect()
{
	return EVMDialect::strictAssemblyForEVMObjects(langutil::EVMVersion{});
}

fuzztest::Domain<yul::AST> YulASTDomain()
{
	return fuzztest::Map(
		[](Program const& _program) { return lift(_program, defaultDialect()); },
		ProgramDomain()
	);
}

}
