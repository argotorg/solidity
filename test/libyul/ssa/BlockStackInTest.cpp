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
 * Unit tests for the choice of a block's stack-in.
 */

#include <test/Common.h>

#include <test/libsolidity/util/SoltestErrors.h>

#include <libyul/backends/evm/ssa/io/Parser.h>
#include <libyul/backends/evm/ssa/stack/BlockStackIn.h>

#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>

#include <boost/test/unit_test.hpp>

using namespace solidity::yul::ssa;

namespace solidity::yul::test
{

/// A join of two predecessors with one phi. The graph only provides the slots, the stacks the edges arrive with
/// and the liveness on entry to the join are written by hand in each case.
struct JoinFixture
{
	JoinFixture()
	{
		auto parsed = io::parse(
			"#0:\n"
			"    v0 = const 0x2a\n"
			"    v1 = builtin @calldataload v0\n"
			"    v2 = builtin @calldataload v1\n"
			"    v3 = builtin @calldataload v2\n"
			"    branch v3, #1, #2\n"
			"#1: preds: #0\n"
			"    upsilon v2 -> ^v6\n"
			"    jump #3\n"
			"#2: preds: #0\n"
			"    upsilon v0 -> ^v6\n"
			"    jump #3\n"
			"#3: preds: #1, #2\n"
			"    v6 = phi\n"
			"    builtin @sstore v6, v6\n"
			"    main_exit\n",
			EVMDialect::strictAssemblyForEVMObjects(solidity::test::CommonOptions::get().evmVersion())
		);
		soltestAssert(parsed, "The graph must parse.");
		graphs = std::move(*parsed);
		SSACFG const& cfg = *graphs->mainGraph();
		auto const& entryInstructions = cfg.block(SSACFG::BlockId{0}).instructions;
		phi = cfg.block(join).instructions.front();
		literal = StackSlot::makeValue(cfg, entryInstructions.at(0));
		first = StackSlot::makeValue(cfg, entryInstructions.at(1));
		second = StackSlot::makeValue(cfg, entryInstructions.at(2));
		shadow = StackSlot::makeShadow(cfg, phi);
	}

	std::unique_ptr<ControlFlowGraphs> graphs;
	SSACFG::BlockId left{1};
	SSACFG::BlockId right{2};
	SSACFG::BlockId join{3};
	InstId phi;
	StackSlot literal = StackSlot::makeJunk();
	StackSlot first = StackSlot::makeJunk();
	StackSlot second = StackSlot::makeJunk();
	StackSlot shadow = StackSlot::makeJunk();
	spill::SpillSet spillSet;
};

BOOST_FIXTURE_TEST_SUITE(BlockStackIn, JoinFixture)

BOOST_AUTO_TEST_CASE(pending_copy_of_a_literal_does_not_widen_the_join)
{
	// left renamed its input in place above a dead slot, right has two dead slots and its copy pending
	std::vector<stack::IncomingEdge> const edges{
		{left, {first, shadow}},
		{right, {first, second}, {{shadow, literal}}}
	};
	StackData const stackIn = stack::chooseBlockStackIn(*graphs->mainGraph(), edges, {}, {phi}, spillSet, true);
	BOOST_CHECK_MESSAGE(stackIn == (StackData{StackSlot::makeJunk(), shadow}), stackToString(stackIn));

	BOOST_CHECK(stack::shuffleAcrossEdge(edges[0], stackIn, {phi}, spillSet, true).trace.empty());
	ShuffleTrace const expectedRightTrace{
		ShuffleOp::pop(),
		ShuffleOp::push(literal),
		ShuffleOp::rename(StackDepth{0}, shadow)
	};
	BOOST_CHECK(stack::shuffleAcrossEdge(edges[1], stackIn, {phi}, spillSet, true).trace == expectedRightTrace);
	BOOST_CHECK(spillSet.numSpilled() == 0);
}

BOOST_AUTO_TEST_CASE(pending_copy_of_a_live_value_on_a_single_edge)
{
	// the input of the pending copy stays live in the join, the slot below it is dead
	std::vector<stack::IncomingEdge> const edges{{left, {first, second}, {{shadow, second}}}};
	LivenessAnalysis::LivenessData liveIn;
	liveIn.insert(second.value());
	StackData const stackIn = stack::chooseBlockStackIn(*graphs->mainGraph(), edges, liveIn, {phi}, spillSet, true);
	BOOST_CHECK_MESSAGE(stackIn == (StackData{StackSlot::makeJunk(), second, shadow}), stackToString(stackIn));

	ShuffleTrace const expectedTrace{ShuffleOp::dup(StackDepth{1}), ShuffleOp::rename(StackDepth{0}, shadow)};
	BOOST_CHECK(stack::shuffleAcrossEdge(edges[0], stackIn, {phi}, spillSet, true).trace == expectedTrace);
	BOOST_CHECK(spillSet.numSpilled() == 0);
}

BOOST_AUTO_TEST_SUITE_END()

}
