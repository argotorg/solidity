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
 * Unit tests for KnowledgeBase
 */

#include <test/Common.h>

#include <test/libsolidity/util/SoltestErrors.h>

#include <test/libyul/Common.h>

#include <libyul/Object.h>
#include <libyul/YulStack.h>
#include <libyul/optimiser/ASTCopier.h>
#include <libyul/optimiser/KnowledgeBase.h>
#include <libyul/optimiser/SSAValueTracker.h>
#include <libyul/optimiser/CommonSubexpressionEliminator.h>
#include <libyul/optimiser/LabelIDDispenser.h>
#include <libyul/backends/evm/EVMDialect.h>

#include <boost/test/unit_test.hpp>

using namespace solidity::langutil;

namespace solidity::yul::test
{

class KnowledgeBaseTest
{
protected:
	KnowledgeBase constructKnowledgeBase(std::string const& _source)
	{
		YulStack yulStack = parseYul(_source);
		solUnimplementedAssert(yulStack.parserResult()->subObjects.empty(), "Tests with subobjects not supported.");
		soltestAssert(!yulStack.hasErrors());
		m_object = yulStack.parserResult();

		auto astRoot = std::get<Block>(yul::ASTCopier{}(m_object->code()->root()));
		LabelIDDispenser dispenser(m_object->code()->labels());
		std::set<YulName> reserved;
		OptimiserStepContext context{*m_object->dialect(), dispenser, reserved, 0};
		CommonSubexpressionEliminator::run(context, astRoot);

		m_ssaValues(astRoot);
		for (auto const& [name, expression]: m_ssaValues.values())
			m_values[name].value = expression;

		m_object->setCode(std::make_shared<AST>(*m_object->dialect(), dispenser, std::move(astRoot)));
		return KnowledgeBase(
			[this](YulName _var) { return util::valueOrNullptr(m_values, _var); },
			*m_object->dialect()
		);
	}

	std::shared_ptr<Object> m_object;
	SSAValueTracker m_ssaValues;
	std::map<YulName, AssignedValue> m_values;
};

BOOST_FIXTURE_TEST_SUITE(KnowledgeBase, KnowledgeBaseTest)

BOOST_AUTO_TEST_CASE(basic)
{
	yul::KnowledgeBase kb = constructKnowledgeBase(R"({
		let a := calldataload(0)
		let b := calldataload(0)
		let zero := 0
		let c := add(b, 0)
		let d := mul(b, 0)
		let e := sub(a, b)
	})");

	const auto& labels = m_object->code()->labels();
	std::map<std::string, YulName> labelToIdMap;
	for (auto const label: {"a", "b", "c", "e", "zero"})
	{
		auto const maybeNodeId = labels.findIDForLabel(label);
		yulAssert(maybeNodeId);
		labelToIdMap[label] = *maybeNodeId;
	}
	BOOST_CHECK(!kb.knownToBeDifferent(labelToIdMap["a"], labelToIdMap["b"]));
	// This only works if the variable names are the same.
	// It assumes that SSA+CSE+Simplifier actually replaces the variables.
	BOOST_CHECK(!kb.valueIfKnownConstant(labelToIdMap["a"]));
	BOOST_CHECK(kb.valueIfKnownConstant(labelToIdMap["zero"]) == u256(0));
	BOOST_CHECK(kb.differenceIfKnownConstant(labelToIdMap["a"], labelToIdMap["b"]) == u256(0));
	BOOST_CHECK(kb.differenceIfKnownConstant(labelToIdMap["a"], labelToIdMap["c"]) == u256(0));
	BOOST_CHECK(kb.valueIfKnownConstant(labelToIdMap["e"]) == u256(0));
}

BOOST_AUTO_TEST_CASE(difference)
{
	yul::KnowledgeBase kb = constructKnowledgeBase(R"({
		let a := calldataload(0)
		let b := add(a, 200)
		let c := add(a, 220)
		let d := add(12, c)
		let e := sub(c, 12)
	})");

	const auto& labels = m_object->code()->labels();
	std::map<std::string, YulName> labelToIdMap;
	for (auto const label: {"a", "b", "c", "d", "e"})
	{
		auto const maybeNodeId = labels.findIDForLabel(label);
		yulAssert(maybeNodeId);
		labelToIdMap[label] = *maybeNodeId;
	}
	BOOST_CHECK(kb.differenceIfKnownConstant(labelToIdMap["c"], labelToIdMap["b"]) ==
		u256(20)
	);
	BOOST_CHECK(kb.differenceIfKnownConstant(labelToIdMap["b"], labelToIdMap["c"]) ==
		u256(-20)
	);
	BOOST_CHECK(!kb.knownToBeDifferentByAtLeast32(labelToIdMap["b"], labelToIdMap["c"]));
	BOOST_CHECK(kb.knownToBeDifferentByAtLeast32(labelToIdMap["b"], labelToIdMap["d"]));
	BOOST_CHECK(kb.knownToBeDifferentByAtLeast32(labelToIdMap["a"], labelToIdMap["b"]));
	BOOST_CHECK(kb.knownToBeDifferentByAtLeast32(labelToIdMap["b"], labelToIdMap["a"]));

	BOOST_CHECK(kb.differenceIfKnownConstant(labelToIdMap["e"], labelToIdMap["a"]) == u256(208));
	BOOST_CHECK(kb.differenceIfKnownConstant(labelToIdMap["e"], labelToIdMap["b"]) == u256(8));
	BOOST_CHECK(kb.differenceIfKnownConstant(labelToIdMap["a"], labelToIdMap["e"]) == u256(-208));
	BOOST_CHECK(kb.differenceIfKnownConstant(labelToIdMap["b"], labelToIdMap["e"]) == u256(-8));
}


BOOST_AUTO_TEST_SUITE_END()

}
