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

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>
#include <libyul/backends/evm/ssa/JunkAdmittingBlocksFinder.h>
#include <libyul/backends/evm/ssa/io/DotExporterBase.h>

#include <libsolutil/StringUtils.h>
#include <libsolutil/Visitor.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wtautological-compare"
#include <fmt/ranges.h>
#pragma GCC diagnostic pop

#include <range/v3/view/zip.hpp>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::yul;
using namespace solidity::yul::ssa;

namespace
{

std::string formatPhi(SSACFG const& _cfg, SSACFG::PhiValue const& _phiValue)
{
	auto const transform = [&](SSACFG::ValueId const& valueId) { return valueId.str(_cfg); };
	std::vector<std::string> formattedArgs;
	formattedArgs.reserve(_phiValue.arguments.size());
	for (auto const& [arg, entry]: ranges::zip_view(_phiValue.arguments | ranges::views::transform(transform), _cfg.block(_phiValue.block).entries))
		formattedArgs.push_back(fmt::format("Block {} => {}", entry.value, arg));
	if (!formattedArgs.empty())
		return fmt::format("φ(\\l\\\n\t{}\\l\\\n)", fmt::join(formattedArgs, ",\\l\\\n\t"));
	else
		return "φ()";
}

class SSACFGDotExporter: public io::DotExporterBase
{
public:
	SSACFGDotExporter(SSACFG const& _cfg, size_t _functionIndex, LivenessAnalysis const* _liveness):
		DotExporterBase(_cfg, _functionIndex),
		m_liveness(_liveness)
	{
		if (_liveness)
			m_junkAdmittingBlocks = std::make_unique<JunkAdmittingBlocksFinder>(_cfg, _liveness->topologicalSort());
	}

protected:
	void writeBlockLabel(std::ostream& _out, SSACFG::BlockId _blockId) override
	{
		auto const& block = m_cfg.block(_blockId);
		auto const valueToString = [&](SSACFG::ValueId const& valueId) { return valueId.str(m_cfg); };

		if (m_liveness)
		{
			_out << fmt::format(
				"\\\nBlock {}; ({}, max {})\\n",
				_blockId.value,
				m_liveness->topologicalSort().preOrderIndexOf(_blockId.value),
				m_liveness->topologicalSort().maxSubtreePreOrderIndexOf(_blockId.value)
			);
			_out << fmt::format(
				"LiveIn: {}\\l\\\n",
				fmt::join(m_liveness->liveIn(_blockId) | ranges::views::transform([&](auto const& liveIn) { return valueToString(SSACFG::ValueId{liveIn.first}) + fmt::format("[{}]", liveIn.second); }), ", ")
			);
			_out << fmt::format(
				"LiveOut: {}\\l\\n",
				fmt::join(m_liveness->liveOut(_blockId) | ranges::views::transform([&](auto const& liveOut) { return valueToString(SSACFG::ValueId{liveOut.first}) + fmt::format("[{}]", liveOut.second); }), ", ")
			);
			auto const usedVariables = m_liveness->used(_blockId);
			_out << fmt::format(
				"Used: {}\\l\\n",
				fmt::join(usedVariables | ranges::views::transform([&](auto const& used) { return valueToString(SSACFG::ValueId{used.first}) + fmt::format("[{}]", used.second); }), ", ")
			);
		}
		else
			_out << fmt::format("\\\nBlock {}\\n", _blockId.value);

		for (auto const& phi: block.phis)
		{
			auto const& phiInfo = m_cfg.phiInfo(phi);
			_out << fmt::format("phi{} := {}\\l\\\n", phi.value(), formatPhi(m_cfg, phiInfo));
		}
		for (auto const& operation: block.operations)
		{
			std::string const label = std::visit(GenericVisitor{
				[&](SSACFG::Call const& _call) {
					return _call.function.get().name.str();
				},
				[&](SSACFG::BuiltinCall const& _call) {
					return _call.builtin.get().name;
				},
				[&](SSACFG::LiteralAssignment const&)
				{
					yulAssert(operation.inputs.size() == 1);
					return operation.inputs.back().str(m_cfg);
				}
			}, operation.kind);
			if (!operation.outputs.empty())
				_out << fmt::format(
					"{} := ",
					fmt::join(operation.outputs | ranges::views::transform(valueToString), ", ")
				);
			if (std::holds_alternative<SSACFG::LiteralAssignment>(operation.kind))
				_out << fmt::format(
					"{}\\l\\\n",
					escapeLabel(label)
				);
			else
				_out << fmt::format(
					"{}({})\\l\\\n",
					escapeLabel(label),
					fmt::join(operation.inputs | ranges::views::transform(valueToString), ", ")
				);
		}
	}

	std::vector<std::pair<std::string, std::string>> blockNodeAttributes(SSACFG::BlockId _blockId) override
	{
		if (m_junkAdmittingBlocks && m_junkAdmittingBlocks->allowsAdditionOfJunk(_blockId))
			return {{"fillcolor", "\"#FF746C\""}, {"style", "filled"}};
		return {};
	}

	EdgeStyle edgeStyle(SSACFG::BlockId _source, SSACFG::BlockId _target) override
	{
		if (m_liveness && m_liveness->topologicalSort().backEdge(_source, _target))
			return EdgeStyle::Dashed;
		return EdgeStyle::Solid;
	}

private:
	LivenessAnalysis const* m_liveness;
	std::unique_ptr<JunkAdmittingBlocksFinder> m_junkAdmittingBlocks;
};

}

std::string SSACFG::ValueId::str(SSACFG const& _cfg) const
{
	if (!hasValue())
		return "INVALID";
	switch (kind())
	{
		case Kind::Literal:  return toCompactHexWithPrefix(_cfg.literalInfo(*this).value);
		case Kind::Variable: return fmt::format("v{}", value());
		case Kind::Phi: return fmt::format("phi{}", value());
		case Kind::Unreachable: return "[unreachable]";
	}
	unreachable();
}


std::string SSACFG::toDot(
	bool _includeDiGraphDefinition,
	std::optional<size_t> _functionIndex,
	LivenessAnalysis const* _liveness
) const
{
	SSACFGDotExporter exporter(*this, _functionIndex.value_or(function ? 1 : 0), _liveness);
	if (function)
		return exporter.exportFunction(*function, _includeDiGraphDefinition);
	else
		return exporter.exportBlocks(entry, _includeDiGraphDefinition);
}
