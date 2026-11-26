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

/// Property test for the shape of the code that Yul optimizer steps leave behind
///
/// The test generates a program, runs a random sequence of optimizer steps on it, followed by one of the steps
/// in shapeChecks (with the steps these need run first), and checks the shape that step promises. Whatever the
/// sequence, the result also has to pass the analyzer and declare every name only once.
///
/// The checks deliberately do not reuse the analyses the steps are built on (TerminationFinder,
/// ControlFlowSideEffectsCollector, CallGraphGenerator, assignedVariableNames), so that a bug there is not checked
/// against itself. They only share the dialect's description of the builtins.
///
/// The programs come from YulProgramGenerator.h, which also lists what they do not cover. As they have no recursion,
/// the test adds functions whose calls form cycles, which CircularReferencesPruner removes and UnusedPruner keeps.
///
/// Limitations:
///   - nothing is executed: a step that keeps the shape but changes the behaviour passes

#include <test/fuzztest/libyul/OptimizerStepSequence.h>
#include <test/fuzztest/libyul/YulProgramGenerator.h>

#include <libyul/AST.h>
#include <libyul/AsmAnalysis.h>
#include <libyul/AsmAnalysisInfo.h>
#include <libyul/AsmPrinter.h>
#include <libyul/Dialect.h>
#include <libyul/Object.h>
#include <libyul/Utilities.h>
#include <libyul/YulStack.h>
#include <libyul/optimiser/ASTWalker.h>

#include <libsolutil/Exceptions.h>
#include <libsolutil/Visitor.h>

#include <boost/exception/diagnostic_information.hpp>

#include <fuzztest/fuzztest.h>
#include <gtest/gtest.h>

#include <fmt/format.h>

#include <range/v3/algorithm/all_of.hpp>
#include <range/v3/algorithm/any_of.hpp>
#include <range/v3/algorithm/find_if.hpp>
#include <range/v3/range/conversion.hpp>
#include <range/v3/view/drop.hpp>
#include <range/v3/view/join.hpp>
#include <range/v3/view/map.hpp>

#include <cstddef>
#include <cstdint>
#include <functional>
#include <iterator>
#include <map>
#include <memory>
#include <optional>
#include <set>
#include <string>
#include <utility>
#include <variant>
#include <vector>

using namespace solidity;
using namespace solidity::yul;

namespace solidity::yul::test
{

namespace
{

class ShapeChecker: public ASTWalker
{
public:
	/// @returns the first violation of the shape in @a _ast, if there is one.
	std::optional<std::string> firstViolation(Block const& _ast)
	{
		(*this)(_ast);
		return m_violation;
	}

protected:
	void report(std::string _violation)
	{
		if (!m_violation)
			m_violation = std::move(_violation);
	}

private:
	std::optional<std::string> m_violation;
};

class NamesDeclaredOnce: public ShapeChecker
{
public:
	using ASTWalker::operator();
	void operator()(VariableDeclaration const& _declaration) override
	{
		for (NameWithDebugData const& variable: _declaration.variables)
			declare(variable.name);
		ASTWalker::operator()(_declaration);
	}
	void operator()(FunctionDefinition const& _function) override
	{
		declare(_function.name);
		for (NameWithDebugData const& variable: _function.parameters)
			declare(variable.name);
		for (NameWithDebugData const& variable: _function.returnVariables)
			declare(variable.name);
		ASTWalker::operator()(_function);
	}

private:
	void declare(YulName const& _name)
	{
		if (!m_declared.insert(_name).second)
			report(fmt::format("{} is declared more than once", _name.str()));
	}

	std::set<YulName> m_declared;
};

class FunctionsInOutermostBlock: public ShapeChecker
{
public:
	using ASTWalker::operator();
	void operator()(Block const& _block) override
	{
		++m_blockDepth;
		ASTWalker::operator()(_block);
		--m_blockDepth;
	}
	void operator()(FunctionDefinition const& _function) override
	{
		if (m_blockDepth != 1)
			report(fmt::format("function {} is not in the outermost block", _function.name.str()));
		ASTWalker::operator()(_function);
	}

private:
	std::size_t m_blockDepth = 0;
};

class NoLoopInitializers: public ShapeChecker
{
public:
	using ASTWalker::operator();
	void operator()(ForLoop const& _loop) override
	{
		if (!_loop.pre.statements.empty())
			report("a loop has an initializer");
		ASTWalker::operator()(_loop);
	}
};

class OperandsAreVariables: public ShapeChecker
{
public:
	explicit OperandsAreVariables(Dialect const& _dialect): m_dialect(_dialect) {}

	using ASTWalker::operator();
	void operator()(FunctionCall const& _call) override
	{
		BuiltinFunction const* builtin = resolveBuiltinFunction(_call.functionName, m_dialect);
		for (std::size_t i = 0; i < _call.arguments.size(); ++i)
			if (!builtin || !builtin->literalArgument(i))
				requireVariable(_call.arguments[i], "an argument of a call");
	}
	void operator()(If const& _if) override
	{
		requireVariable(*_if.condition, "the condition of an if");
		(*this)(_if.body);
	}
	void operator()(Switch const& _switch) override
	{
		requireVariable(*_switch.expression, "the expression of a switch");
		for (Case const& switchCase: _switch.cases)
			(*this)(switchCase.body);
	}
	void operator()(ForLoop const& _loop) override
	{
		// The step leaves the condition alone: there is no place to move its parts to.
		(*this)(_loop.pre);
		(*this)(_loop.body);
		(*this)(_loop.post);
	}

private:
	void requireVariable(Expression const& _expression, char const* _role)
	{
		if (!std::holds_alternative<Identifier>(_expression))
			report(fmt::format("{} is not a variable: {}", _role, std::visit(AsmPrinter{m_dialect}, _expression)));
	}

	Dialect const& m_dialect;
};

class AssignedVariables: public ASTWalker
{
public:
	static std::set<YulName> in(Block const& _block)
	{
		AssignedVariables collector;
		collector(_block);
		return std::move(collector.m_assigned);
	}

	using ASTWalker::operator();
	void operator()(Assignment const& _assignment) override
	{
		for (Identifier const& variable: _assignment.variableNames)
			m_assigned.insert(variable.name);
		ASTWalker::operator()(_assignment);
	}

private:
	std::set<YulName> m_assigned;
};

/// The pseudo-SSA form of the SSATransform: variables can still be assigned, but only by copying
/// from variables that are never assigned
class AssignedVariablesOnlyCopied: public ShapeChecker
{
public:
	AssignedVariablesOnlyCopied(Dialect const& _dialect, Block const& _ast):
		m_dialect(_dialect), m_assigned(AssignedVariables::in(_ast))
	{}

	using ASTWalker::operator();
	void operator()(Assignment const& _assignment) override
	{
		Identifier const* value = std::get_if<Identifier>(_assignment.value.get());
		if (_assignment.variableNames.size() != 1 || !value || m_assigned.contains(value->name))
			report(fmt::format(
				"an assignment is not a copy of a variable that is never assigned: {}",
				AsmPrinter{m_dialect}(_assignment)
			));
		for (Identifier const& variable: _assignment.variableNames)
			m_assignedSoFar.insert(variable.name);
	}
	void operator()(VariableDeclaration const& _declaration) override
	{
		bool const declaresAssigned = ranges::any_of(
			_declaration.variables,
			[&](NameWithDebugData const& _variable) { return m_assigned.contains(_variable.name); }
		);
		// `let a_1 := a` where control flow joins and `let a := a_1` are how an assigned variable gets its value
		// read and set.
		if (Identifier const* value = std::get_if<Identifier>(_declaration.value.get()))
		{
			if (declaresAssigned && m_assigned.contains(value->name))
				report(fmt::format(
					"an assigned variable is declared as a copy of another assigned variable: {}",
					AsmPrinter{m_dialect}(_declaration)
				));
			return;
		}
		if (declaresAssigned)
			report(fmt::format(
				"an assigned variable is not declared as a copy of a variable: {}",
				AsmPrinter{m_dialect}(_declaration)
			));
		if (_declaration.value)
			visit(*_declaration.value);
	}
	void operator()(ForLoop const& _loop) override
	{
		std::set<YulName> const enclosingLoops = m_assignedInEnclosingLoops;
		for (Block const* block: {&_loop.body, &_loop.post})
			m_assignedInEnclosingLoops.merge(AssignedVariables::in(*block));

		// The step leaves the condition alone: there is no place to declare a variable for it.
		(*this)(_loop.pre);
		(*this)(_loop.body);
		(*this)(_loop.post);

		// After the loop, the step reads these variables through a new SSA name again
		m_assignedInEnclosingLoops = enclosingLoops;
	}
	void operator()(FunctionDefinition const& _function) override
	{
		for (NameWithDebugData const& variable: _function.returnVariables)
			m_returnVariables.insert(variable.name);
		std::set<YulName> const enclosingLoops = std::exchange(m_assignedInEnclosingLoops, {});
		ASTWalker::operator()(_function);
		m_assignedInEnclosingLoops = enclosingLoops;
	}
	void operator()(Identifier const& _identifier) override
	{
		if (m_assigned.contains(_identifier.name) && !mayBeReadDirectly(_identifier.name))
			report(fmt::format("{} is assigned, and read directly instead of through an SSA name", _identifier.name.str()));
	}

private:
	/// The step reads a return variable directly, not through an SSA name:
	///   - before its first assignment: unlike for a parameter, it declares no SSA name for the initial value
	///   - inside a loop that assigns it: https://github.com/argotorg/solidity/issues/17305
	/// Both because IntroduceControlFlowSSA does not count return variables as in scope.
	bool mayBeReadDirectly(YulName const& _name) const
	{
		return
			m_returnVariables.contains(_name) &&
			(!m_assignedSoFar.contains(_name) || m_assignedInEnclosingLoops.contains(_name));
	}

	Dialect const& m_dialect;
	std::set<YulName> m_assigned;
	std::set<YulName> m_returnVariables;
	std::set<YulName> m_assignedSoFar;
	std::set<YulName> m_assignedInEnclosingLoops;
};

class FunctionBodies: public ASTWalker
{
public:
	static std::map<YulName, Block const*> in(Block const& _ast)
	{
		FunctionBodies collector;
		collector(_ast);
		return std::move(collector.m_bodies);
	}

	using ASTWalker::operator();
	void operator()(FunctionDefinition const& _function) override
	{
		m_bodies[_function.name] = &_function.body;
		ASTWalker::operator()(_function);
	}

private:
	std::map<YulName, Block const*> m_bodies;
};

class LeaveFinder: public ASTWalker
{
public:
	static bool containsLeave(Block const& _block)
	{
		LeaveFinder finder;
		finder(_block);
		return finder.m_found;
	}

	using ASTWalker::operator();
	void operator()(Leave const&) override { m_found = true; }
	/// A `leave` in a nested function only leaves that one
	void operator()(FunctionDefinition const&) override {}

private:
	bool m_found = false;
};

bool callsNonContinuing(Dialect const& _dialect, std::set<YulName> const& _nonContinuingFunctions, Expression const& _expression)
{
	FunctionCall const* call = std::get_if<FunctionCall>(&_expression);
	if (!call)
		return false;
	if (ranges::any_of(call->arguments, [&](Expression const& _argument) {
		return callsNonContinuing(_dialect, _nonContinuingFunctions, _argument);
	}))
		return true;
	if (BuiltinFunction const* builtin = resolveBuiltinFunction(call->functionName, _dialect))
		return !builtin->controlFlowSideEffects.canContinue;
	return _nonContinuingFunctions.contains(std::get<Identifier>(call->functionName).name);
}

bool neverContinues(Dialect const& _dialect, std::set<YulName> const& _nonContinuingFunctions, Statement const& _statement)
{
	return std::visit(util::GenericVisitor{
		[&](ExpressionStatement const& _expressionStatement) {
			return callsNonContinuing(_dialect, _nonContinuingFunctions, _expressionStatement.expression);
		},
		[&](VariableDeclaration const& _declaration) {
			return _declaration.value && callsNonContinuing(_dialect, _nonContinuingFunctions, *_declaration.value);
		},
		[&](Assignment const& _assignment) {
			return callsNonContinuing(_dialect, _nonContinuingFunctions, *_assignment.value);
		},
		[](auto const&) { return false; }
	}, _statement);
}

/// The user functions that certainly never continue: those without a `leave` that have a statement that never
/// continues at the top level of their body. A subset of what the ControlFlowSideEffectsCollector finds, which
/// the step uses, so that the check does not flag code the step rightly keeps.
std::set<YulName> nonContinuingFunctions(Dialect const& _dialect, Block const& _ast)
{
	std::map<YulName, Block const*> const bodies = FunctionBodies::in(_ast);
	std::set<YulName> nonContinuing;
	for (bool found = true; found;)
	{
		found = false;
		for (auto const& [function, body]: bodies)
			if (
				!nonContinuing.contains(function) &&
				!LeaveFinder::containsLeave(*body) &&
				ranges::any_of(body->statements, [&](Statement const& _statement) {
					return neverContinues(_dialect, nonContinuing, _statement);
				})
			)
			{
				nonContinuing.insert(function);
				found = true;
			}
	}
	return nonContinuing;
}

class NoCodeAfterUnconditionalExit: public ShapeChecker
{
public:
	NoCodeAfterUnconditionalExit(Dialect const& _dialect, Block const& _ast):
		m_dialect(_dialect), m_nonContinuingFunctions(nonContinuingFunctions(_dialect, _ast))
	{}

	using ASTWalker::operator();
	void operator()(Block const& _block) override
	{
		std::vector<Statement> const& statements = _block.statements;
		auto const exit = ranges::find_if(statements, [&](Statement const& _statement) {
			return exitsUnconditionally(_statement);
		});
		auto const isCode = [](Statement const& _statement) {
			return !std::holds_alternative<FunctionDefinition>(_statement);
		};
		if (exit != statements.end())
			if (auto const code = ranges::find_if(std::next(exit), statements.end(), isCode); code != statements.end())
				report(fmt::format(
					"code follows {}: {}",
					std::visit(AsmPrinter{m_dialect}, *exit),
					std::visit(AsmPrinter{m_dialect}, *code)
				));
		ASTWalker::operator()(_block);
	}

private:
	bool exitsUnconditionally(Statement const& _statement) const
	{
		return
			std::holds_alternative<Break>(_statement) ||
			std::holds_alternative<Continue>(_statement) ||
			std::holds_alternative<Leave>(_statement) ||
			neverContinues(m_dialect, m_nonContinuingFunctions, _statement);
	}

	Dialect const& m_dialect;
	std::set<YulName> m_nonContinuingFunctions;
};

/// The user functions that each function calls and those that the outermost code calls
struct Calls
{
	std::map<YulName, std::set<YulName>> ofFunction;
	std::set<YulName> ofOutermostCode;
};

class CallCollector: public ASTWalker
{
public:
	static Calls callsIn(Block const& _ast)
	{
		CallCollector collector;
		collector(_ast);
		return std::move(collector.m_calls);
	}

	using ASTWalker::operator();
	void operator()(FunctionDefinition const& _function) override
	{
		m_calls.ofFunction.try_emplace(_function.name);
		std::optional<YulName> const caller = std::exchange(m_caller, _function.name);
		ASTWalker::operator()(_function);
		// code after the definition belongs to the enclosing function or the outermost code
		m_caller = caller;
	}
	void operator()(FunctionCall const& _call) override
	{
		if (Identifier const* callee = std::get_if<Identifier>(&_call.functionName))
			(m_caller ? m_calls.ofFunction[*m_caller] : m_calls.ofOutermostCode).insert(callee->name);
		ASTWalker::operator()(_call);
	}

private:
	Calls m_calls;
	std::optional<YulName> m_caller;
};

struct FunctionsGrouped
{
	static std::optional<std::string> firstViolation(Block const& _ast)
	{
		auto const isFunction = [](Statement const& _statement) {
			return std::holds_alternative<FunctionDefinition>(_statement);
		};
		if (
			!_ast.statements.empty() &&
			std::holds_alternative<Block>(_ast.statements.front()) &&
			ranges::all_of(_ast.statements | ranges::views::drop(1), isFunction)
		)
			return std::nullopt;
		return "the outermost block is not a block followed by function definitions only";
	}
};

struct FunctionsCalled
{
	static std::optional<std::string> firstViolation(Block const& _ast)
	{
		Calls const calls = CallCollector::callsIn(_ast);
		std::set<YulName> called = calls.ofFunction | ranges::views::values | ranges::views::join | ranges::to<std::set>;
		called.insert(calls.ofOutermostCode.begin(), calls.ofOutermostCode.end());
		for (YulName const& function: calls.ofFunction | ranges::views::keys)
			if (!called.contains(function))
				return fmt::format("function {} is never called", function.str());
		return std::nullopt;
	}
};

struct FunctionsReachable
{
	static std::optional<std::string> firstViolation(Block const& _ast)
	{
		Calls const calls = CallCollector::callsIn(_ast);
		std::set<YulName> reached = calls.ofOutermostCode;
		std::vector<YulName> toVisit(reached.begin(), reached.end());
		while (!toVisit.empty())
		{
			YulName const caller = toVisit.back();
			toVisit.pop_back();
			for (YulName const& callee: calls.ofFunction.at(caller))
				if (reached.insert(callee).second)
					toVisit.push_back(callee);
		}
		for (YulName const& function: calls.ofFunction | ranges::views::keys)
			if (!reached.contains(function))
				return fmt::format("function {} is not reachable from the outermost code", function.str());
		return std::nullopt;
	}
};

using ShapeCheck = std::function<std::optional<std::string>(Dialect const&, Block const&)>;

/// The checked steps, by their abbreviations, with how a result breaks the shape the step promises:
///   - FunctionHoister (h): all function definitions are in the outermost block
///   - FunctionGrouper (g): the outermost block is a block followed by function definitions only
///   - ForLoopInitRewriter (o): no loop has an initializer
///   - ExpressionSplitter (x): outside of loop conditions, the conditions of ifs, the expressions of switches and
///     the arguments of calls, except literal arguments of builtins, are variables
///   - SSATransform (a): a variable that is assigned only ever gets the value of a variable that is never
///     assigned, and is only read to be copied into a variable that is never assigned, or in a loop condition.
///     A return variable is also read directly before its first assignment and inside a loop that assigns it.
///   - DeadCodeEliminator (D): only function definitions follow a `break`, `continue`, `leave` or a statement
///     that calls a builtin or user function that never continues
///   - CircularReferencesPruner (l): every function is reachable through calls from the outermost code
///   - UnusedPruner (u): every function is called somewhere
std::map<char, ShapeCheck> const shapeChecks{
	{'h', [](Dialect const&, Block const& _ast) { return FunctionsInOutermostBlock{}.firstViolation(_ast); }},
	{'g', [](Dialect const&, Block const& _ast) { return FunctionsGrouped::firstViolation(_ast); }},
	{'o', [](Dialect const&, Block const& _ast) { return NoLoopInitializers{}.firstViolation(_ast); }},
	{'x', [](Dialect const& _dialect, Block const& _ast) { return OperandsAreVariables{_dialect}.firstViolation(_ast); }},
	{'a', [](Dialect const& _dialect, Block const& _ast) { return AssignedVariablesOnlyCopied{_dialect, _ast}.firstViolation(_ast); }},
	{'D', [](Dialect const& _dialect, Block const& _ast) { return NoCodeAfterUnconditionalExit{_dialect, _ast}.firstViolation(_ast); }},
	{'l', [](Dialect const&, Block const& _ast) { return FunctionsReachable::firstViolation(_ast); }},
	{'u', [](Dialect const&, Block const& _ast) { return FunctionsCalled::firstViolation(_ast); }},
};

/// Runs @a _steps and then @a _checkedStep on @a _source, with the steps these need before them, and asserts
/// that the result has the shape that @a _checkedStep promises, passes the analyzer and declares every name once.
void checkShape(std::string const& _source, std::string const& _steps, char const _checkedStep)
{
	YulStack stack;
	ASSERT_TRUE(stack.parseAndAnalyze("source", _source)) << _source;
	std::shared_ptr<Object const> const object = stack.parserResult();
	ASSERT_TRUE(object && object->hasCode() && object->analysisInfo) << _source;
	Dialect const& dialect = *object->dialect();

	std::string const steps = _steps + _checkedStep;
	std::string const sequence = prerequisitesOf(steps) + steps;
	Block const ast = runSteps(*object, sequence);
	auto const context = [&] {
		return fmt::format("steps: {}\nresult:\n{}\nsource:\n{}", sequence, AsmPrinter{dialect}(ast), _source);
	};

	try
	{
		AsmAnalyzer::analyzeStrictAssertCorrect(dialect, ast, object->summarizeStructure());
	}
	catch (util::Exception const& _exception)
	{
		FAIL() << "The result does not pass the analyzer: " << _exception.what() << "\n" << context();
	}
	std::optional<std::string> const redeclared = NamesDeclaredOnce{}.firstViolation(ast);
	ASSERT_FALSE(redeclared.has_value()) << *redeclared << "\n" << context();

	std::optional<std::string> const violation = shapeChecks.at(_checkedStep)(dialect, ast);
	ASSERT_FALSE(violation.has_value()) << fmt::format(
		"The result does not have the shape that step {} promises: {}\n{}",
		_checkedStep,
		*violation,
		context()
	);
}

std::uint8_t constexpr numCycleFunctions = 3;

/// Calls between the functions c0, c1, ..., which the test adds to a generated program
struct CallCycles
{
	std::vector<std::pair<std::uint8_t, std::uint8_t>> callerAndCallee;
	std::vector<std::uint8_t> calledFromOutermostCode;
};

/// Recursion is fine here: nothing is executed
std::string withCallCycles(std::string const& _program, CallCycles const& _cycles)
{
	std::vector<std::string> bodies(numCycleFunctions);
	for (auto const& [caller, callee]: _cycles.callerAndCallee)
		bodies[caller] += fmt::format("c{}() ", callee);
	// Before the program, which ends in a `return` that would make the calls dead code
	std::string source = "{\n";
	for (std::uint8_t const callee: _cycles.calledFromOutermostCode)
		source += fmt::format("c{}()\n", callee);
	source += _program + "\n";
	for (std::size_t function = 0; function < numCycleFunctions; ++function)
		source += fmt::format("function c{}() {{ {}}}\n", function, bodies[function]);
	return source + "}\n";
}

struct FuzzInput
{
	std::vector<Instruction> instructions;
	CallCycles cycles;
	std::string randomSteps;
	char checkedStep;
};

auto inputDomain()
{
	auto const cycleFunction = fuzztest::InRange<std::uint8_t>(0, numCycleFunctions - 1);
	return fuzztest::StructOf<FuzzInput>(
		instructionsDomain(),
		fuzztest::StructOf<CallCycles>(
			fuzztest::VectorOf(fuzztest::PairOf(cycleFunction, cycleFunction)).WithMaxSize(6),
			fuzztest::VectorOf(cycleFunction).WithMaxSize(2)
		),
		stepsDomain(),
		fuzztest::ElementOf(shapeChecks | ranges::views::keys | ranges::to<std::vector>)
	);
}

}

static void StepsLeavePromisedShape(FuzzInput const& _input)
{
	std::string const source = withCallCycles(buildProgram(_input.instructions), _input.cycles);
	try
	{
		checkShape(source, _input.randomSteps, _input.checkedStep);
	}
	catch (...)
	{
		FAIL() << fmt::format(
			"Exception: {}\nrandom steps: {}\nchecked step: {}\nsource:\n{}",
			boost::current_exception_diagnostic_information(),
			_input.randomSteps,
			_input.checkedStep,
			source
		);
	}
}

FUZZ_TEST(OptimizerStepProperty, StepsLeavePromisedShape)
	.WithDomains(inputDomain());

/// Runs each checked step on code that breaks every shape
TEST(OptimizerStepProperty, EachStepEstablishesItsShape)
{
	std::string const source = R"({
		let a := calldataload(0)
		for { let i := add(a, mload(a)) } lt(i, add(a, 3)) { i := add(i, mload(i)) } {
			function inner(p) -> r {
				r := add(p, sload(mul(p, 2)))
				if lt(sload(r), mload(p)) { r := 1 }
			}
			a := inner(add(a, sload(i)))
		}
		switch mload(add(a, 1))
		case 0 { a := 2 }
		default { a := mul(a, 3) }
		sstore(a, add(a, mload(a)))
		function unused() {
			revert(0, 0)
			sstore(0, 0)
		}
	})";
	YulStack stack;
	ASSERT_TRUE(stack.parseAndAnalyze("source", source));
	std::shared_ptr<Object const> const object = stack.parserResult();
	Block const unchanged = runSteps(*object, "");

	for (auto const& [step, firstViolation]: shapeChecks)
	{
		EXPECT_TRUE(firstViolation(*object->dialect(), unchanged).has_value())
			<< "the code already has the shape of step " << step;
		EXPECT_NO_FATAL_FAILURE(checkShape(source, "", step)) << step;
	}
}

TEST(OptimizerStepProperty, CheckersCatchEachViolation)
{
	struct Case
	{
		char step;
		char const* source;
		/// Part of the reported violation, nullptr if there must be none
		char const* violation;
	};
	std::vector<Case> const cases{
		// FunctionHoister
		{'h', "{ { function f() {} } }", "is not in the outermost block"},
		// FunctionGrouper
		{'g', "{ let x := 1 function f() {} }", "is not a block followed by function"},
		// ForLoopInitRewriter
		{'o', "{ for { let i := 0 } lt(i, 3) { i := add(i, 1) } {} }", "has an initializer"},
		// ExpressionSplitter
		{'x', "{ let x := calldatasize() sstore(x, add(x, x)) }", "an argument of a call is not a variable: add(x, x)"},
		{'x', "{ let x := calldatasize() sstore(x, 1) }", "an argument of a call is not a variable: 1"},
		{'x', "{ if calldatasize() {} }", "the condition of an if is not a variable"},
		{'x', "{ switch calldatasize() case 0 {} default {} }", "the expression of a switch is not a variable"},
		{'x', "{ for {} lt(calldatasize(), 3) {} {} }", nullptr},
		{'x', "{ let x := linkersymbol(\"a\") sstore(x, x) }", nullptr},
		// SSATransform
		{
			'a',
			"{ let x := calldatasize() let a := add(x, 1) a := x }",
			"an assigned variable is not declared as a copy of a variable"
		},
		{
			'a',
			"{ let x := calldatasize() let a a := x }",
			"an assigned variable is not declared as a copy of a variable"
		},
		{
			'a',
			"{ let x := calldatasize() let a := x let b := a a := x b := x }",
			"is declared as a copy of another assigned variable"
		},
		{
			'a',
			"{ let x := calldatasize() let a := x a := add(x, 1) }",
			"an assignment is not a copy of a variable that is never assigned"
		},
		{
			'a',
			"{ let x := calldatasize() let a := x let b := x a := x b := a }",
			"an assignment is not a copy of a variable that is never assigned"
		},
		{
			'a',
			"{ function f() -> p, q {} let x := calldatasize() let a := x let b := x a, b := f() }",
			"an assignment is not a copy of a variable that is never assigned"
		},
		{
			'a',
			"{ let x := calldatasize() let a := x a := x sstore(a, x) }",
			"is assigned, and read directly instead of through an SSA name"
		},
		{
			'a',
			"{ function f() -> r { let x := calldatasize() if x { r := x } sstore(r, x) } }",
			"is assigned, and read directly instead of through an SSA name"
		},
		{
			'a',
			"{ for {} lt(calldatasize(), 3) {} { function f() -> r { let x := calldatasize() r := x sstore(r, x) } } }",
			"is assigned, and read directly instead of through an SSA name"
		},
		{'a', "{ function f() -> r { let x := calldatasize() sstore(r, x) r := x } }", nullptr},
		{
			'a',
			"{ function f() -> r { let x := calldatasize() r := x for {} lt(x, 3) {} { sstore(r, x) r := x } } }",
			nullptr
		},
		// DeadCodeEliminator
		{
			'D',
			"{ let x := calldatasize() if x { revert(0, 0) sstore(x, x) } }",
			"code follows revert(0, 0): sstore(x, x)"
		},
		{'D', "{ for {} 1 {} { break sstore(0, 0) } }", "code follows break: sstore(0, 0)"},
		{'D', "{ for {} 1 {} { continue sstore(0, 0) } }", "code follows continue: sstore(0, 0)"},
		{'D', "{ function f() { leave sstore(0, 0) } }", "code follows leave: sstore(0, 0)"},
		{'D', "{ let x := calldatasize() if x { revert(0, 0) } sstore(x, x) }", nullptr},
		{'D', "{ revert(0, 0) function f() {} }", nullptr},
		{'D', "{ function f() { revert(0, 0) } f() sstore(0, 0) }", "code follows f(): sstore(0, 0)"},
		{
			'D',
			"{ function f() -> r { revert(0, 0) } let x := add(f(), 1) sstore(x, x) }",
			"code follows let x := add(f(), 1): sstore(x, x)"
		},
		{
			'D',
			"{ function f() -> r { revert(0, 0) } let x := 0 x := f() sstore(x, x) }",
			"code follows x := f(): sstore(x, x)"
		},
		{'D', "{ function f() { g() } function g() { revert(0, 0) } f() sstore(0, 0) }", "code follows f(): sstore(0, 0)"},
		{'D', "{ function f() { if calldatasize() { leave } revert(0, 0) } f() sstore(0, 0) }", nullptr},
		{'D', "{ function f() { if calldatasize() { revert(0, 0) } } f() sstore(0, 0) }", nullptr},
		{'D', "{ function f() { f() } f() sstore(0, 0) }", nullptr},
		// CircularReferencesPruner
		{'l', "{ function f() { g() } function g() { f() } }", "is not reachable from the outermost code"},
		{'l', "{ function f() { g() } function g() {} f() }", nullptr},
		{'l', "{ function f() { f() } }", "function f is not reachable from the outermost code"},
		{'l', "{ function f() { g() } function g() { f() } g() }", nullptr},
		// UnusedPruner
		{'u', "{ function f() {} }", "function f is never called"},
		{'u', "{ function f() { f() } }", nullptr},
		{'u', "{ function f() { g() } function g() { f() } }", nullptr},
	};
	for (Case const& checkerCase: cases)
	{
		SCOPED_TRACE(fmt::format("step {}, source: {}", checkerCase.step, checkerCase.source));
		YulStack stack;
		ASSERT_TRUE(stack.parseAndAnalyze("source", checkerCase.source));
		std::shared_ptr<Object const> const object = stack.parserResult();
		std::optional<std::string> const found =
			shapeChecks.at(checkerCase.step)(*object->dialect(), runSteps(*object, ""));
		if (checkerCase.violation)
		{
			if (!found)
				ADD_FAILURE() << "no violation found";
			else
				EXPECT_NE(found->find(checkerCase.violation), std::string::npos) << *found;
		}
		else
			EXPECT_FALSE(found.has_value()) << *found;
	}
}

/// Checks the parsed code directly: runSteps would disambiguate away the duplicate name
TEST(OptimizerStepProperty, NamesDeclaredOnceCatchesRedeclaration)
{
	YulStack stack;
	ASSERT_TRUE(stack.parseAndAnalyze("source", "{ { let x } { let x } }"));
	std::optional<std::string> const redeclared = NamesDeclaredOnce{}.firstViolation(stack.parserResult()->code()->root());
	ASSERT_TRUE(redeclared.has_value());
	EXPECT_NE(redeclared->find("x is declared more than once"), std::string::npos) << *redeclared;
}

}
