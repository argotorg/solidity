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

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>

#include <libsolutil/Visitor.h>

#include <range/v3/algorithm/find.hpp>
#include <range/v3/algorithm/find_if.hpp>
#include <range/v3/range/conversion.hpp>

#include <range/v3/view/filter.hpp>
#include <range/v3/view/reverse.hpp>

using namespace solidity::yul::ssa;

namespace
{
constexpr auto excludingLiteralsFilter(SSACFG const& _cfg)
{
	return [&_cfg](LivenessAnalysis::LivenessData::Value const& _valueId) -> bool
	{
		return !std::holds_alternative<SSACFG::LiteralValue>(_cfg.valueInfo(_valueId));
	};
}
constexpr auto unreachableFilter(SSACFG const& _cfg)
{
	return [&_cfg](LivenessAnalysis::LivenessData::Value const& _valueId) -> bool
	{
		return std::holds_alternative<SSACFG::UnreachableValue>(_cfg.valueInfo(_valueId));
	};
}
}

bool LivenessAnalysis::LivenessData::contains(Value const& _valueId) const
{
	return findEntry(_valueId) != m_liveCounts.end();
}

LivenessAnalysis::LivenessData::Count LivenessAnalysis::LivenessData::count(Value const& _valueId) const
{
	if (
		auto const it = findEntry(_valueId);
		it != m_liveCounts.end()
	)
		return it->second;
	return 0;
}

LivenessAnalysis::LivenessData::LiveCounts::const_iterator LivenessAnalysis::LivenessData::begin() const
{
	return m_liveCounts.begin();
}

LivenessAnalysis::LivenessData::LiveCounts::const_iterator LivenessAnalysis::LivenessData::end() const
{
	return m_liveCounts.end();
}

LivenessAnalysis::LivenessData::LiveCounts::size_type LivenessAnalysis::LivenessData::size() const
{
	return m_liveCounts.size();
}

bool LivenessAnalysis::LivenessData::empty() const { return m_liveCounts.empty(); }

void LivenessAnalysis::LivenessData::insert(Value const& _value, Count _count)
{
	if (_count == 0)
		return;

	auto it = findEntry(_value);
	if (it != m_liveCounts.end())
		it->second += _count;
	else
		m_liveCounts.emplace_back(_value, _count);
}

LivenessAnalysis::LivenessData& LivenessAnalysis::LivenessData::maxUnion(LivenessData const& _other)
{
	for (auto const& [value, count]: _other.m_liveCounts)
	{
		auto it = findEntry(value);
		if (it != m_liveCounts.end())
			it->second = std::max(it->second, count);
		else
			m_liveCounts.emplace_back(value, count);
	}
	return *this;
}

LivenessAnalysis::LivenessData& LivenessAnalysis::LivenessData::operator+=(LivenessData const& _other)
{
	for (auto const& [valueId, count]: _other.m_liveCounts)
		insert(valueId, count);
	return *this;
}

LivenessAnalysis::LivenessData& LivenessAnalysis::LivenessData::operator-=(LivenessData const& _other)
{
	std::erase_if(m_liveCounts, [&](auto const& entry) { return _other.contains(entry.first); });
	return *this;
}

void LivenessAnalysis::LivenessData::erase(Value const& _value)
{
	if (
		auto const it = findEntry(_value);
		it != m_liveCounts.end()
	)
		m_liveCounts.erase(it);
}

void LivenessAnalysis::LivenessData::remove(Value const& _value, Count _count)
{
	if (_count == 0)
		return;

	auto it = findEntry(_value);
	if (it != m_liveCounts.end())
	{
		if (it->second <= _count)
			m_liveCounts.erase(it);
		else
			it->second -= _count;
	}
}


LivenessAnalysis::LivenessData LivenessAnalysis::blockExitValues(SSACFG::BlockId const& _blockId) const
{
	LivenessData result;
	util::GenericVisitor exitVisitor{
		[](SSACFG::BasicBlock::MainExit const&) {},
		[&](SSACFG::BasicBlock::FunctionReturn const& _functionReturn)
		{
			for (auto const& valueId: _functionReturn.returnValues | ranges::views::filter(excludingLiteralsFilter(m_cfg)))
				result.insert(valueId);
		},
		[&](SSACFG::BasicBlock::JumpTable const& _jt)
		{
			if (excludingLiteralsFilter(m_cfg)(_jt.value))
				result.insert(_jt.value);
		},
		[](SSACFG::BasicBlock::Jump const&) {},
		[&](SSACFG::BasicBlock::ConditionalJump const& _conditionalJump)
		{
			if (excludingLiteralsFilter(m_cfg)(_conditionalJump.condition))
				result.insert(_conditionalJump.condition);
		},
		[](SSACFG::BasicBlock::Terminated const&) {}};
	std::visit(exitVisitor, m_cfg.block(_blockId).exit);
	return result;
}


LivenessAnalysis::LivenessData::LiveCounts::iterator LivenessAnalysis::LivenessData::findEntry(Value const& _value)
{
	return ranges::find_if(m_liveCounts, [&](auto const& _entry) { return _entry.first == _value; });
}

LivenessAnalysis::LivenessData::LiveCounts::const_iterator LivenessAnalysis::LivenessData::findEntry(Value const& _value) const
{
	return ranges::find_if(m_liveCounts, [&](auto const& _entry) { return _entry.first == _value; });
}

LivenessAnalysis::LivenessAnalysis(SSACFG const& _cfg):
	m_cfg(_cfg),
	m_topologicalSort(_cfg),
	m_loopNestingForest(m_topologicalSort),
	m_liveIns(_cfg.numBlocks()),
	m_liveOuts(_cfg.numBlocks()),
	m_operationLiveOuts(_cfg.numBlocks())
{
	runDagDfs();
	for (auto const loopRootNode: m_loopNestingForest.loopRootNodes())
		runLoopTreeDfs(loopRootNode);

	fillOperationsLiveOut();
}

LivenessAnalysis::LivenessData LivenessAnalysis::used(SSACFG::BlockId const _blockId) const
{
	auto used = liveIn(_blockId);
	for (auto const& [valueId, count]: liveOut(_blockId))
		used.remove(valueId, count);
	return used;
}

void LivenessAnalysis::runDagDfs()
{
	// SSA Book, Algorithm 9.2
	for (auto const blockIdValue: m_topologicalSort.postOrder())
	{
		// post-order traversal
		SSACFG::BlockId blockId{blockIdValue};
		auto const& block = m_cfg.block(blockId);

		// live <- PhiUses(B)
		LivenessData live{};
		block.forEachExit(
			[&](SSACFG::BlockId const& _successor)
			{
				for (auto const& phi: m_cfg.block(_successor).phis)
				{
					auto const& info = m_cfg.valueInfo(phi);
					yulAssert(std::holds_alternative<SSACFG::PhiValue>(info), "value info of phi wasn't PhiValue");
					auto const argIndex = m_cfg.phiArgumentIndex(blockId, _successor);
					yulAssert(argIndex < std::get<SSACFG::PhiValue>(info).arguments.size());
					auto const arg = std::get<SSACFG::PhiValue>(info).arguments.at(argIndex);
					if (!std::holds_alternative<SSACFG::LiteralValue>(m_cfg.valueInfo(arg)))
						live.insert(arg);
				}
			});

		// for each S \in succs(B) s.t. (B, S) not a back edge: live <- live \cup (LiveIn(S) - PhiDefs(S))
		block.forEachExit(
			[&](SSACFG::BlockId const& _successor) {
				if (!m_topologicalSort.backEdge(blockId, _successor))
				{
					// LiveIn(S) - PhiDefs(S)
					auto liveInWithoutPhiDefs = m_liveIns[_successor.value];
					for (auto const& phiId: m_cfg.block(_successor).phis)
						liveInWithoutPhiDefs.erase(phiId);
					live.maxUnion(liveInWithoutPhiDefs);
				}
			});

		if (std::holds_alternative<SSACFG::BasicBlock::FunctionReturn>(block.exit))
			for (auto const& returnValue: std::get<SSACFG::BasicBlock::FunctionReturn>(block.exit).returnValues | ranges::views::filter(excludingLiteralsFilter(m_cfg)))
				live.insert(returnValue);

		// clean out unreachables
		live.eraseIf([&](auto const& _entry) { return unreachableFilter(m_cfg)(_entry.first); });

		// LiveOut(B) <- live
		m_liveOuts[blockId.value] = live;

		// for each program point p in B, backwards, do:
		{
			// add value ids to the live set that are used in exit blocks
			live += blockExitValues(blockId);

			for (auto const& op: block.operations | ranges::views::reverse)
			{
				// remove variables defined at p from live
				live.eraseAll(op.outputs | ranges::views::filter(excludingLiteralsFilter(m_cfg)) | ranges::to<std::vector>);
				// add uses at p to live
				live.insertAll(op.inputs | ranges::views::filter(excludingLiteralsFilter(m_cfg)) | ranges::to<std::vector>);
			}
		}

		// livein(b) <- live \cup PhiDefs(B)
		for (auto const& phi: block.phis)
			live.insert(phi);
		m_liveIns[blockId.value] = live;
	}
}

void LivenessAnalysis::runLoopTreeDfs(size_t const _loopHeader)
{
	// SSA Book, Algorithm 9.3
	if (m_loopNestingForest.loopNodes().contains(_loopHeader))
	{
		// the loop header block id
		auto const& block = m_cfg.block(SSACFG::BlockId{_loopHeader});
		// LiveLoop <- LiveIn(B_N) - PhiDefs(B_N)
		auto liveLoop = m_liveIns[_loopHeader];
		for (auto const& phi: block.phis)
			liveLoop.erase(phi);
		// must be live out of header if live in of children
		m_liveOuts[_loopHeader].maxUnion(liveLoop);
		// for each blockId \in children(loopHeader)
		for (size_t blockIdValue = 0; blockIdValue < m_cfg.numBlocks(); ++blockIdValue)
			if (m_loopNestingForest.loopParents()[blockIdValue] == _loopHeader)
			{
				// propagate loop liveness information down to the loop header's children
				m_liveIns[blockIdValue].maxUnion(liveLoop);
				m_liveOuts[blockIdValue].maxUnion(liveLoop);

				runLoopTreeDfs(blockIdValue);
			}
	}
}

void LivenessAnalysis::fillOperationsLiveOut()
{
	for (SSACFG::BlockId blockId{0}; blockId.value < m_cfg.numBlocks(); ++blockId.value)
	{
		auto const& operations = m_cfg.block(blockId).operations;
		auto& liveOuts = m_operationLiveOuts[blockId.value];
		liveOuts.resize(operations.size());
		if (!operations.empty())
		{
			auto live = m_liveOuts[blockId.value];
			live += blockExitValues(blockId);
			auto rit = liveOuts.rbegin();
			for (auto const& op: operations | ranges::views::reverse)
			{
				*rit = live;
				for (auto const& output: op.outputs | ranges::views::filter(excludingLiteralsFilter(m_cfg)))
					live.erase(output);
				for (auto const& input: op.inputs | ranges::views::filter(excludingLiteralsFilter(m_cfg)))
					live.insert(input);
				++rit;
			}
		}
	}
}
