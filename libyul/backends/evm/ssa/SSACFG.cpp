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

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>
#include <libyul/backends/evm/ssa/JunkAdmittingBlocksFinder.h>
#include <libyul/backends/evm/ssa/LivenessAnalysis.h>
#include <libyul/backends/evm/ssa/io/DotExporterBase.h>

#include <libsolutil/StringUtils.h>

#include <fmt/ranges.h>

#include <range/v3/view/iota.hpp>
#include <range/v3/view/transform.hpp>
#include <range/v3/view/zip.hpp>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::yul;
using namespace solidity::yul::ssa;

namespace
{

class SSACFGDotExporter: public io::DotExporterBase
{
public:
	SSACFGDotExporter(SSACFG const& _cfg, size_t _functionIndex, LivenessAnalysis const* _liveness, ControlFlowGraphs const* _controlFlow):
		DotExporterBase(_cfg, _functionIndex),
		m_liveness(_liveness),
		m_controlFlow(_controlFlow)
	{
		if (_liveness)
			m_junkAdmittingBlocks = std::make_unique<JunkAdmittingBlocksFinder>(_cfg, _liveness->dfsTree());
	}

protected:
	void writeBlockLabel(std::ostream& _out, BlockId _blockId) override
	{
		auto const& block = m_cfg.block(_blockId);
		auto const valueToString = [&](InstId const& valueId) { return valueId.str(m_cfg); };

		if (m_liveness)
		{
			_out << fmt::format(
				"\\\nBlock {}; ({}, max {})\\n",
				_blockId.value,
				m_liveness->dfsTree().preOrderIndexOf(_blockId),
				m_liveness->dfsTree().maxSubtreePreOrderIndexOf(_blockId)
			);
			auto const livenessToString = [&](LivenessAnalysis::LivenessData const& _values, ShadowLiveness::ShadowSet const& _shadows) {
				std::vector<std::string> entries;
				for (auto const& [value, count]: _values)
					entries.push_back(valueToString(value) + fmt::format("[{}]", count));
				for (InstId const phi: _shadows)
					entries.push_back(fmt::format("^{}[1]", valueToString(phi)));
				return fmt::format("{}", fmt::join(entries, ", "));
			};
			ShadowLiveness::ShadowSet usedShadows;
			for (InstId const phi: m_liveness->liveInShadows(_blockId))
				if (!m_liveness->liveOutShadows(_blockId).contains(phi))
					usedShadows.insert(phi);
			_out << fmt::format(
				"LiveIn: {}\\l\\\n",
				livenessToString(m_liveness->liveIn(_blockId), m_liveness->liveInShadows(_blockId))
			);
			_out << fmt::format(
				"LiveOut: {}\\l\\n",
				livenessToString(m_liveness->liveOut(_blockId), m_liveness->liveOutShadows(_blockId))
			);
			_out << fmt::format(
				"Used: {}\\l\\n",
				livenessToString(m_liveness->used(_blockId), usedShadows)
			);
		}
		else
			_out << fmt::format("\\\nBlock {}\\n", _blockId.value);

		// Phis, upsilons and BuiltinCall / Call in program order. A phi reads its shadow and an upsilon
		// writes the shadow of its phi. Trailing Projections of multi-return calls are rendered as
		// standalone lines following their producer.
		for (InstId const instId: block.instructions)
		{
			SSACFG::Inst const& inst = m_cfg.inst(instId);
			if (inst.isPhi())
				_out << fmt::format("{0} := φ(^{0})\\l\\\n", valueToString(instId));
			if (inst.isUpsilon())
				_out << fmt::format(
					"^{} := {}\\l\\\n",
					valueToString(m_cfg.upsilonPhi(instId)),
					valueToString(inst.inputs.at(0))
				);
			if (!inst.isOperation())
				continue;
			std::string label;
			switch (inst.opcode)
			{
			case InstOpcode::Call:
			{
				auto const graphID = m_cfg.callPayload(instId).graphID;
				label = m_controlFlow ? m_controlFlow->functionGraph(graphID)->name : fmt::format("func{}", graphID);
				break;
			}
			case InstOpcode::BuiltinCall:
				label = m_cfg.evmDialect.builtin(m_cfg.builtinPayload(instId).builtin).name;
				break;
			case InstOpcode::MemoryGuard:
				if (m_controlFlow && m_controlFlow->memoryGuard)
					label = fmt::format("memoryguard<{}>", toCompactHexWithPrefix(*m_controlFlow->memoryGuard));
				else
					label = "memoryguard";
				break;
			default:
				yulAssert(false);
			}
			if (m_cfg.numReturnsOf(instId) >= 1)
				_out << fmt::format("{} := ", valueToString(instId));
			_out << fmt::format(
				"{}({})\\l\\\n",
				escapeLabel(label),
				fmt::join(inst.inputs | ranges::views::transform(valueToString), ", ")
			);
			for (InstId const projId: m_cfg.projectionsOf(instId))
				_out << fmt::format(
					"{} := {}.proj({})\\l\\\n",
					valueToString(projId),
					valueToString(instId),
					static_cast<unsigned>(m_cfg.projectionIndex(projId))
				);
		}
	}

	std::vector<std::pair<std::string, std::string>> blockNodeAttributes(BlockId _blockId) override
	{
		if (m_junkAdmittingBlocks && m_junkAdmittingBlocks->allowsAdditionOfJunk(_blockId))
			return {{"fillcolor", "\"#FF746C\""}, {"style", "filled"}};
		return {};
	}

	EdgeStyle edgeStyle(BlockId _source, BlockId _target) override
	{
		if (m_liveness && m_liveness->dfsTree().backEdge(_source, _target))
			return EdgeStyle::Dashed;
		return EdgeStyle::Solid;
	}

private:
	LivenessAnalysis const* m_liveness;
	ControlFlowGraphs const* m_controlFlow;
	std::unique_ptr<JunkAdmittingBlocksFinder> m_junkAdmittingBlocks;
};

}

std::string SSACFG::toDot(
	bool _includeDiGraphDefinition,
	std::optional<size_t> _functionIndex,
	LivenessAnalysis const* _liveness,
	ControlFlowGraphs const* _controlFlow
) const
{
	SSACFGDotExporter exporter(*this, _functionIndex.value_or(isMainGraph() ? 0 : 1), _liveness, _controlFlow);
	if (!isMainGraph())
		return exporter.exportFunction(*this, _includeDiGraphDefinition);
	else
		return exporter.exportBlocks(entry, _includeDiGraphDefinition);
}
