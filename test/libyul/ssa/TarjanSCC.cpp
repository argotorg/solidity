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
/**
 * Unit tests for the Tarjan SCC utility.
 */

#include <libyul/backends/evm/ssa/util/TarjanSCC.h>

#include <boost/test/data/monomorphic.hpp>
#include <boost/test/data/test_case.hpp>
#include <boost/test/unit_test.hpp>

#include <fmt/format.h>
#include <fmt/ranges.h>

#include <range/v3/algorithm/sort.hpp>
#include <range/v3/view/transform.hpp>

#include <cstdint>
#include <ostream>
#include <string>
#include <vector>

namespace solidity::yul::test::ssa
{

using NodeID = std::uint32_t;
using Graph = std::vector<std::vector<NodeID>>;
using SCCList = std::vector<std::vector<NodeID>>;

namespace
{

namespace bdata = boost::unit_test::data;

SCCList compute(Graph const& _g)
{
	return solidity::yul::ssa::util::computeStronglyConnectedComponents<NodeID>(_g);
}

SCCList canonicalize(SCCList _sccs)
{
	for (auto& scc: _sccs)
		ranges::sort(scc);
	ranges::sort(_sccs);
	return _sccs;
}

std::string formatSCCs(SCCList const& _sccs)
{
	auto const formatScc = [](std::vector<NodeID> const& _scc) {
		return fmt::format("{{{}}}", fmt::join(_scc, ", "));
	};
	return fmt::format("{{{}}}", fmt::join(_sccs | ranges::views::transform(formatScc), ", "));
}

boost::test_tools::predicate_result sccsEqual(SCCList const& _actual, SCCList const& _expected)
{
	SCCList const canonicalActual = canonicalize(_actual);
	SCCList const canonicalExpected = canonicalize(_expected);
	if (canonicalActual == canonicalExpected)
		return true;
	boost::test_tools::predicate_result result(false);
	result.message()
		<< "SCC partitions differ (compared as sets of sets).\n"
		<< "  actual:   " << formatSCCs(canonicalActual) << "\n"
		<< "  expected: " << formatSCCs(canonicalExpected);
	return result;
}

struct PartitionCase
{
	std::string name;
	Graph graph;
	SCCList expectedSCCs;
};

std::ostream& operator<<(std::ostream& _os, PartitionCase const& _case)
{
	return _os << _case.name;
}

std::vector<PartitionCase> const partitionCases = {
	{"empty_graph", {}, {}},
	{"single_node_no_edges", Graph(1), {{0}}},
	{"single_node_self_loop", {{0}}, {{0}}},
	{"two_cycle", {{1}, {0}}, {{0, 1}}},
	{"three_cycle", {{1}, {2}, {0}}, {{0, 1, 2}}},
	{"linear_chain", {{1}, {2}, {3}, {}}, {{0}, {1}, {2}, {3}}},
	// 0 <-> 1, plus self-loop on 0. Yields one SCC {0, 1}.
	{"self_loop_inside_two_cycle", {{0, 1}, {0}}, {{0, 1}}},
	// 0 -> 2, 1 -> 2: three singleton SCCs.
	{"dag_with_shared_successor", {{2}, {2}, {}}, {{0}, {1}, {2}}},
	{
		"clrs_example",
		// CLRS, 3rd ed., Fig. 22.9 (relabeled a..h -> 0..7).
		// 0 -> 1
		// 1 -> 2, 4, 5
		// 2 -> 3, 6
		// 3 -> 2, 7
		// 4 -> 0, 5
		// 5 -> 6
		// 6 -> 5, 7
		// 7 -> 7
		{{1}, {2, 4, 5}, {3, 6}, {2, 7}, {0, 5}, {6}, {5, 7}, {7}},
		{{0, 1, 4}, {2, 3}, {5, 6}, {7}},
	},
	{
		"multiple_disjoint_components",
		// Four components: 0 <-> 1, 2 <-> 3, 4 -> 5.
		{{1}, {0}, {3}, {2}, {5}, {}},
		{{0, 1}, {2, 3}, {4}, {5}},
	},
	{
		"nested_sccs_with_cross_edges",
		// Two SCCs connected by an inter-SCC edge: 0 <-> 1 (A), 2 <-> 3 (B), 1 -> 2.
		{{1}, {0, 2}, {3}, {2}},
		{{0, 1}, {2, 3}},
	},
	// 0 -> 1, node 2 isolated: 2 still emitted as its own SCC.
	{"unreachable_node_still_emitted", {{1}, {}, {}}, {{0}, {1}, {2}}},
};

}

BOOST_AUTO_TEST_SUITE(TarjanSCC)

BOOST_DATA_TEST_CASE(partition, bdata::make(partitionCases), testCase)
{
	BOOST_CHECK(sccsEqual(compute(testCase.graph), testCase.expectedSCCs));
}

BOOST_AUTO_TEST_SUITE_END()

}
