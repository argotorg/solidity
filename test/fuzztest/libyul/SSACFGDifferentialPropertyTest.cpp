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
 * Differential property: for every generated Yul program and calldata, executing the SSA CFG built by
 * `SSACFGBuilder` (before and after the `transform/` pipeline) with `SSACFGInterpreter` produces the same
 * outcome, effect trace, memory, storage and return data as executing the Yul AST with the Yul interpreter.
 *
 * Both interpreters share `InterpreterState` and `EVMInstructionInterpreter`, so builtin stubs cancel out and
 * a mismatch localises to control flow, calls, or the Phi/Upsilon plumbing.
 */

#include <test/fuzztest/libyul/SSACFGInterpreter.h>
#include <test/fuzztest/libyul/YulProgramGenerator.h>

#include <test/tools/yulInterpreter/Interpreter.h>

#include <libyul/AST.h>
#include <libyul/AsmAnalysis.h>
#include <libyul/AsmAnalysisInfo.h>
#include <libyul/AsmPrinter.h>
#include <libyul/Exceptions.h>
#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>
#include <libyul/backends/evm/ssa/SSACFGBuilder.h>
#include <libyul/backends/evm/ssa/transform/OptimizationPipeline.h>

#include <liblangutil/ErrorReporter.h>
#include <liblangutil/Exceptions.h>

#include <fuzztest/fuzztest.h>
#include <gtest/gtest.h>

#include <absl/random/random.h>

#include <cstdint>
#include <iostream>
#include <map>
#include <memory>
#include <sstream>
#include <string>
#include <vector>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;

namespace solidity::yul::test
{

namespace
{

enum class Outcome
{
	Returned,    ///< Fell off the end of the main block / returned from the main graph.
	Terminated,  ///< A terminating builtin ran (stop / return / revert / invalid / selfdestruct).
	Limit,       ///< Step, trace or nesting limit. Counted differently by the two interpreters: not comparable.
	Assertion    ///< yulAssert fired inside the interpreter: an invariant violation, always a failure.
};

char const* toString(Outcome const _outcome)
{
	switch (_outcome)
	{
	case Outcome::Returned: return "returned";
	case Outcome::Terminated: return "terminated";
	case Outcome::Limit: return "limit";
	case Outcome::Assertion: return "assertion";
	}
	return "?";
}

struct RunResult
{
	Outcome outcome = Outcome::Returned;
	std::string assertionMessage;
	/// `InterpreterState::dumpTraceAndState`: effect trace, memory, storage, transient storage.
	std::string dump;
	bytes returndata;
};

InterpreterState freshState(std::vector<std::uint8_t> const& _calldata)
{
	InterpreterState state;
	state.calldata = bytes(_calldata.begin(), _calldata.end());
	// Lifted programs terminate by construction (bounded loops, DAG call graph); these only guard mutation
	// artefacts and are treated as "not comparable" when hit.
	state.maxSteps = 100000;
	state.maxTraceSize = 10000;
	state.maxExprNesting = 512;
	return state;
}

RunResult capture(Outcome const _outcome, InterpreterState const& _state)
{
	RunResult result;
	result.outcome = _outcome;
	std::ostringstream dump;
	_state.dumpTraceAndState(dump, /*_disableMemoryTrace=*/false);
	result.dump = dump.str();
	result.returndata = _state.returndata;
	return result;
}

RunResult assertionResult(YulAssertion const& _assertion)
{
	RunResult result;
	result.outcome = Outcome::Assertion;
	result.assertionMessage = _assertion.what();
	return result;
}

/// The Yul interpreter reports termination and limits by exception; normalise to the same shape.
RunResult runYul(AST const& _ast, std::vector<std::uint8_t> const& _calldata)
{
	InterpreterState state = freshState(_calldata);
	Outcome outcome = Outcome::Returned;
	try
	{
		Interpreter::run(state, _ast, /*_disableExternalCalls=*/true, /*_disableMemoryTrace=*/false);
	}
	catch (ExplicitlyTerminated const&)
	{
		outcome = Outcome::Terminated;
	}
	catch (InterpreterTerminatedGeneric const&)
	{
		outcome = Outcome::Limit;
	}
	catch (YulAssertion const& _assertion)
	{
		return assertionResult(_assertion);
	}
	return capture(outcome, state);
}

RunResult runSSACFG(ControlFlowGraphs const& _controlFlow, std::vector<std::uint8_t> const& _calldata)
{
	try
	{
		SSACFGInterpreter::RunResult result = SSACFGInterpreter::run(
			freshState(_calldata), _controlFlow, /*_disableMemoryTrace=*/false
		);
		Outcome outcome = Outcome::Returned;
		switch (result.outcome)
		{
		case SSACFGInterpreter::Outcome::Returned: outcome = Outcome::Returned; break;
		case SSACFGInterpreter::Outcome::Terminated: outcome = Outcome::Terminated; break;
		case SSACFGInterpreter::Outcome::Limit: outcome = Outcome::Limit; break;
		}
		return capture(outcome, result.state);
	}
	catch (YulAssertion const& _assertion)
	{
		return assertionResult(_assertion);
	}
}

void expectSameBehaviour(RunResult const& _expected, RunResult const& _actual, std::string const& _stage)
{
	ASSERT_NE(_expected.outcome, Outcome::Assertion) << _stage << ": Yul interpreter assertion: " << _expected.assertionMessage;
	ASSERT_NE(_actual.outcome, Outcome::Assertion) << _stage << ": SSA CFG interpreter assertion: " << _actual.assertionMessage;
	if (_expected.outcome == Outcome::Limit || _actual.outcome == Outcome::Limit)
		return;
	EXPECT_STREQ(toString(_expected.outcome), toString(_actual.outcome)) << _stage << ": outcome differs";
	EXPECT_EQ(_expected.dump, _actual.dump) << _stage << ": trace / memory / storage differ";
	EXPECT_EQ(_expected.returndata, _actual.returndata) << _stage << ": returndata differs";
}

void SSACFGAgreesWithYulInterpreter(AST const& _ast, std::vector<std::uint8_t> const& _calldata)
{
	auto const* dialect = dynamic_cast<EVMDialect const*>(&_ast.dialect());
	ASSERT_TRUE(dialect) << "Generated AST is not for an EVM dialect.";

	SCOPED_TRACE("Yul program:\n" + AsmPrinter{*dialect}(_ast.root()));

	// The generator is valid by construction; a failure here is a generator bug and should be loud.
	langutil::ErrorList errors;
	langutil::ErrorReporter errorReporter(errors);
	AsmAnalysisInfo analysisInfo;
	AsmAnalyzer analyzer(analysisInfo, errorReporter, *dialect);
	bool const analyzed = analyzer.analyze(_ast.root());
	if (!analyzed || errorReporter.hasErrors())
	{
		std::string messages;
		for (auto const& error: errors)
			messages += std::string(error->what()) + "\n";
		FAIL() << "Generated program fails analysis:\n" << messages;
	}

	RunResult const expected = runYul(_ast, _calldata);

	std::unique_ptr<ControlFlowGraphs> controlFlow = SSACFGBuilder::build(
		analysisInfo, *dialect, _ast.root(), /*_generateDebugInfo=*/false
	);
	expectSameBehaviour(expected, runSSACFG(*controlFlow, _calldata), "raw CFG");
	if (::testing::Test::HasFailure())
		return;

	transform::optimize(*controlFlow);
	expectSameBehaviour(expected, runSSACFG(*controlFlow, _calldata), "optimized CFG");
}

}

FUZZ_TEST(SSACFGDifferentialProperty, SSACFGAgreesWithYulInterpreter)
	.WithDomains(
		gen::YulASTDomain(),
		fuzztest::VectorOf(fuzztest::Arbitrary<std::uint8_t>()).WithMaxSize(64)
	);

// Deterministic smoke test through the same lift + differential path, so a broken pipeline is caught even
// when the random budget happens to produce only trivial programs.
TEST(SSACFGDifferentialProperty, LiftedSumLoopAgrees)
{
	using namespace gen;
	// Indices into the op tables in YulProgramGenerator.cpp: pure 0 = add, 5 = lt; write 1 = sstore.
	Program program;
	program.main.statements.push_back(Stmt{LetStmt{Expr{LiteralExpr{0}}}});  // let v0 := 0
	ForStmt loop;
	loop.pre.statements.push_back(Stmt{LetStmt{Expr{LiteralExpr{0}}}});      // let v1 := 0
	loop.condition = Expr{PureCallExpr{5, {Expr{VarExpr{1}}, Expr{LiteralExpr{3}}}}};  // lt(v1, 3)
	loop.post.statements.push_back(Stmt{AssignStmt{1, Expr{PureCallExpr{0, {Expr{VarExpr{1}}, Expr{LiteralExpr{1}}}}}}});
	loop.body.statements.push_back(Stmt{AssignStmt{0, Expr{PureCallExpr{0, {Expr{VarExpr{0}}, Expr{VarExpr{1}}}}}}});
	program.main.statements.push_back(Stmt{std::move(loop)});
	program.main.statements.push_back(Stmt{WriteStmt{1, {Expr{LiteralExpr{0}}, Expr{VarExpr{0}}}}});  // sstore(0, v0)

	AST const ast = lift(program, defaultDialect());
	std::string const source = AsmPrinter{defaultDialect()}(ast.root());
	EXPECT_NE(source.find("for"), std::string::npos) << source;
	EXPECT_NE(source.find("sstore"), std::string::npos) << source;

	SSACFGAgreesWithYulInterpreter(ast, {});
}

// Samples the domain without mutation and checks every construct the lift can emit actually shows up.
// Guards against the generator silently degenerating (e.g. a subcritical setting that only yields empty blocks).
TEST(SSACFGDifferentialProperty, GeneratorCoversAllConstructs)
{
	constexpr std::size_t samples = 2000;
	std::vector<std::string> const markers{
		"function f", "for {", "switch ", "if ", "break", "continue", "leave",
		"revert(", "return(", "stop()", "invalid()", "sstore(", "mstore(", "sload(", "calldataload(",
		"let ", ":=", " f0(", ", v"
	};
	std::map<std::string, std::size_t> counts;
	absl::BitGen prng;
	fuzztest::Domain<AST> domain = gen::YulASTDomain();
	std::size_t totalStatements = 0;
	std::string largest;
	for (std::size_t i = 0; i < samples; ++i)
	{
		AST const ast = domain.GetRandomValue(prng);
		std::string const source = AsmPrinter{gen::defaultDialect()}(ast.root());
		totalStatements += ast.root().statements.size();
		if (source.size() > largest.size())
			largest = source;
		for (std::string const& marker: markers)
			if (source.find(marker) != std::string::npos)
				++counts[marker];
	}
	std::cout << "Construct frequency over " << samples << " random programs (programs containing it):\n";
	for (std::string const& marker: markers)
		std::cout << "  " << marker << ": " << counts[marker] << "\n";
	std::cout << "Average top-level statements: " << double(totalStatements) / double(samples) << "\n";
	std::cout << "Largest sample:\n" << largest << "\n";
	for (std::string const& marker: markers)
		EXPECT_GT(counts[marker], 0u) << "never generated: " << marker;
}

}
