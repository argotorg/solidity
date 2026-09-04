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
 * A FuzzTest domain of valid Yul programs, handed out as `yul::AST`.
 *
 * The representation FuzzTest mutates (`gen::Program`) is closed under mutation: every variable and function
 * reference is an index that is resolved modulo the number of entities in scope at the point of use, so any value
 * of the type lifts to a program that passes `AsmAnalyzer`. This is the FuzzIL / skeletal-program-enumeration
 * design: validity lives in the representation, not in a generator or a repair step, so FuzzTest's generic
 * mutations (splice, delete, append, tweak an index) stay local and stay valid.
 *
 * `lift` turns a `gen::Program` into a `yul::AST` for the strict EVM dialect. It decides everything the
 * representation leaves open: names, arities, fallbacks when a reference has nothing to refer to (e.g. a variable
 * read in an empty scope becomes a literal), and the hidden iteration bound that keeps every `for` loop finite.
 */
#pragma once

#include <libyul/AST.h>
#include <libyul/ASTForward.h>

#include <fuzztest/fuzztest.h>

#include <cstdint>
#include <optional>
#include <variant>
#include <vector>

namespace solidity::yul
{
class Dialect;
}

namespace solidity::yul::test::gen
{

/// Resolved modulo the number of candidates in scope. For variable references, bit 7 set means "prefer a
/// variable declared before the innermost enclosing block started" (an outer variable), with the low 7 bits
/// indexing into that set; otherwise the low 7 bits index into everything in scope. Assignments to outer
/// variables from inside loops and branches are what create phis, so half of all references aim there.
using Index = std::uint8_t;

struct Expr;

struct LiteralExpr { std::uint8_t value; };
struct VarExpr { Index index; };
/// Pure builtin (arithmetic / comparison / bitwise). `op` selects modulo the op table; missing args are padded.
struct PureCallExpr { std::uint8_t op; std::vector<Expr> args; };
/// State-reading builtin (mload / sload / calldataload / msize).
struct ReadCallExpr { std::uint8_t op; std::vector<Expr> args; };
/// Call to a user function with exactly one return value.
struct UserCallExpr { Index function; std::vector<Expr> args; };

using ExprNode = std::variant<LiteralExpr, VarExpr, PureCallExpr, ReadCallExpr, UserCallExpr>;
struct Expr { ExprNode node; };

struct Stmt;
struct Block { std::vector<Stmt> statements; };

/// `let v := value` or `let v`
struct LetStmt { std::optional<Expr> value; };
/// `let a, b := f(args)` for a user function with any number of returns (zero returns: expression statement).
struct LetCallStmt { Index function; std::vector<Expr> args; };
/// `v := value`; in an empty scope this becomes `pop(value)`.
struct AssignStmt { Index target; Expr value; };
/// `a, b := f(args)` into consecutive in-scope variables starting at `firstTarget`.
struct AssignCallStmt { Index firstTarget; Index function; std::vector<Expr> args; };
/// State-writing builtin statement (mstore / sstore / mstore8 / pop).
struct WriteStmt { std::uint8_t op; std::vector<Expr> args; };
/// Terminating builtin statement (stop / invalid / revert / return).
struct TermStmt { std::uint8_t op; std::vector<Expr> args; };
struct BreakStmt {};
struct ContinueStmt {};
struct LeaveStmt {};
/// `if condition { break | continue | leave }` (kind % 3), the exit dropped where it is not allowed.
/// Conditional loop exits add edges into the loop exit / post block with different reaching definitions.
struct CondExitStmt { Expr condition; std::uint8_t kind; };
struct IfStmt { Expr condition; Block body; };
struct Case { std::uint8_t value; Block body; };
struct SwitchStmt { Expr expression; std::vector<Case> cases; std::optional<Block> defaultCase; };
struct ForStmt { Block pre; Expr condition; Block post; Block body; };
struct BlockStmt { Block body; };

/// Grouped so that nested blocks are one alternative among many: keeps generation subcritical.
/// `ForStmt` is a top-level alternative on purpose: loops are what the SSA builder is sensitive to.
using CompoundNode = std::variant<IfStmt, SwitchStmt, BlockStmt>;
struct CompoundStmt { CompoundNode node; };

using StmtNode = std::variant<
	LetStmt,
	LetCallStmt,
	AssignStmt,
	AssignCallStmt,
	WriteStmt,
	TermStmt,
	BreakStmt,
	ContinueStmt,
	LeaveStmt,
	CondExitStmt,
	ForStmt,
	CompoundStmt
>;
struct Stmt { StmtNode node; };

struct Function { std::uint8_t numParams; std::uint8_t numReturns; Block body; };
struct Program { std::vector<Function> functions; Block main; };

/// Domain over the mutation-closed representation.
fuzztest::Domain<Program> ProgramDomain();

/// Lifts a program to a Yul AST for @a _dialect. Every output passes `AsmAnalyzer`.
yul::AST lift(Program const& _program, Dialect const& _dialect);

/// Domain of Yul ASTs for the strict EVM dialect of the default EVM version: `Map(lift, ProgramDomain())`.
fuzztest::Domain<yul::AST> YulASTDomain();

/// The dialect `YulASTDomain` lifts into.
Dialect const& defaultDialect();

}
