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

#include <libyul/backends/evm/ssa/io/DotExporterBase.h>

#include <libsolutil/Numeric.h>
#include <libsolutil/Visitor.h>

#include <fmt/ranges.h>

#include <deque>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::yul;
using namespace solidity::yul::ssa;
using namespace solidity::yul::ssa::io;

DotExporterBase::DotExporterBase(SSACFG const& _cfg, size_t const _functionIndex, RankDir const _rankDir):
	m_cfg(_cfg),
	m_functionIndex(_functionIndex),
	m_rankDir(_rankDir)
{
}

std::string DotExporterBase::escapeId(std::string_view const _str)
{
	std::string result;
	result.reserve(_str.size());
	for (auto const c: _str)
	{
		if (std::isalnum(static_cast<unsigned char>(c)) || c == '_')
			result += c;
		else
			result += '_';
	}
	return result;
}

std::string DotExporterBase::escapeLabel(std::string_view const _str)
{
	std::string result;
	result.reserve(_str.size());
	for (auto const c: _str)
	{
		if (c == '"' || c == '\\')
			result += '\\';
		result += c;
	}
	return result;
}

std::string DotExporterBase::formatBlockHandle(SSACFG::BlockId _id) const
{
	return fmt::format("Block{}_{}", m_functionIndex, _id.value);
}

std::string DotExporterBase::formatEdge(SSACFG::BlockId _source, SSACFG::BlockId _target, std::optional<std::string> const& _exitPort)
{
	std::string const style = edgeStyle(_source, _target) == EdgeStyle::Dashed ? "dashed" : "solid";
	if (_exitPort)
		return fmt::format("{}Exit:{} -> {} [style=\"{}\"];\n", formatBlockHandle(_source), *_exitPort, formatBlockHandle(_target), style);
	else
		return fmt::format("{}Exit -> {} [style=\"{}\"];\n", formatBlockHandle(_source), formatBlockHandle(_target), style);
}

void DotExporterBase::writeBlock(std::ostream& _out, SSACFG::BlockId const _id)
{
	auto const& block = m_cfg.block(_id);

	auto const attributes = blockNodeAttributes(_id);
	std::string attrStr;
	for (auto const& [name, value]: attributes)
		attrStr += fmt::format("{}={}, ", name, value);
	_out << fmt::format("{} [{}label=\"", formatBlockHandle(_id), attrStr);
	writeBlockLabel(_out, _id);
	_out << "\"];\n";

	std::visit(GenericVisitor{
		[&](SSACFG::BasicBlock::MainExit const&)
		{
			_out << fmt::format("{}Exit [label=\"MainExit\"];\n", formatBlockHandle(_id));
			_out << fmt::format("{} -> {}Exit;\n", formatBlockHandle(_id), formatBlockHandle(_id));
		},
		[&](SSACFG::BasicBlock::Jump const& _jump)
		{
			_out << fmt::format("{} -> {}Exit [arrowhead=none];\n", formatBlockHandle(_id), formatBlockHandle(_id));
			_out << fmt::format("{}Exit [label=\"Jump\" shape=oval];\n", formatBlockHandle(_id));
			_out << formatEdge(_id, _jump.target);
		},
		[&](SSACFG::BasicBlock::ConditionalJump const& _conditionalJump)
		{
			_out << fmt::format("{} -> {}Exit;\n", formatBlockHandle(_id), formatBlockHandle(_id));
			_out << fmt::format(
				"{}Exit [label=\"{{ If {} | {{ <0> Zero | <1> NonZero }}}}\" shape=Mrecord];\n",
				formatBlockHandle(_id), _conditionalJump.condition.str(m_cfg)
			);
			_out << formatEdge(_id, _conditionalJump.zero, "0");
			_out << formatEdge(_id, _conditionalJump.nonZero, "1");
		},
		[&](SSACFG::BasicBlock::FunctionReturn const& fr)
		{
			auto const valueToString = [&](SSACFG::ValueId const& valueId) { return valueId.str(m_cfg); };
			_out << fmt::format("{}Exit [label=\"FunctionReturn[{}]\"];\n",
				formatBlockHandle(_id),
				fmt::join(fr.returnValues | ranges::views::transform(valueToString), ", ")
			);
			_out << fmt::format("{} -> {}Exit;\n", formatBlockHandle(_id), formatBlockHandle(_id));
		},
		[&](SSACFG::BasicBlock::Terminated const&)
		{
			_out << fmt::format("{}Exit [label=\"Terminated\"];\n", formatBlockHandle(_id));
			_out << fmt::format("{} -> {}Exit;\n", formatBlockHandle(_id), formatBlockHandle(_id));
		}
	}, block.exit);
}

void DotExporterBase::traverse(std::ostream& _out, SSACFG::BlockId _entry)
{
	std::vector<std::uint8_t> explored(m_cfg.numBlocks(), false);
	explored[_entry.value] = true;

	std::deque<SSACFG::BlockId> toVisit{};
	toVisit.emplace_back(_entry);

	while (!toVisit.empty())
	{
		auto const id = toVisit.front();
		toVisit.pop_front();
		writeBlock(_out, id);
		m_cfg.block(id).forEachExit(
			[&](SSACFG::BlockId const& _exitBlock)
			{
				if (!explored[_exitBlock.value])
				{
					explored[_exitBlock.value] = true;
					toVisit.emplace_back(_exitBlock);
				}
			}
		);
	}
}

std::string DotExporterBase::exportBlocks(SSACFG::BlockId _entry, bool _wrapInDigraph)
{
	std::ostringstream out;
	if (_wrapInDigraph)
		out << fmt::format("digraph SSACFG {{\nnodesep=0.7;\ngraph[fontname=\"DejaVu Sans\", rankdir={}]\nnode[shape=box,fontname=\"DejaVu Sans\"];\n\n", m_rankDir);
	out << fmt::format("Entry [label=\"Entry\"];\n");
	out << fmt::format("Entry -> {};\n", formatBlockHandle(_entry));
	traverse(out, _entry);
	if (_wrapInDigraph)
		out << "}\n";
	return out.str();
}

std::string DotExporterBase::exportFunction(Scope::Function const& _function, bool _wrapInDigraph)
{
	std::ostringstream out;
	if (_wrapInDigraph)
		out << fmt::format("digraph SSACFG {{\nnodesep=0.7;\ngraph[fontname=\"DejaVu Sans\", rankdir={}]\nnode[shape=box,fontname=\"DejaVu Sans\"];\n\n", m_rankDir);

	static auto constexpr returnsTransform = [](auto const& functionReturnValue) { return escapeLabel(functionReturnValue.get().name.str()); };
	static auto constexpr argsTransform = [](auto const& arg) { return fmt::format("v{}", std::get<1>(arg).value()); };
	auto const entryHandle = fmt::format("FunctionEntry_{}_{}", escapeId(_function.name.str()), m_cfg.entry.value);
	if (!m_cfg.returns.empty())
		out << fmt::format("{} [label=\"function {}:\n {} := {}({})\"];\n",
			entryHandle, escapeLabel(_function.name.str()),
			fmt::join(m_cfg.returns | ranges::views::transform(returnsTransform), ", "),
			escapeLabel(_function.name.str()),
			fmt::join(m_cfg.arguments | ranges::views::transform(argsTransform), ", "));
	else
		out << fmt::format("{} [label=\"function {}:\n {}({})\"];\n",
			entryHandle, escapeLabel(_function.name.str()),
			escapeLabel(_function.name.str()),
			fmt::join(m_cfg.arguments | ranges::views::transform(argsTransform), ", "));
	out << fmt::format("{} -> {};\n", entryHandle, formatBlockHandle(m_cfg.entry));
	traverse(out, m_cfg.entry);

	if (_wrapInDigraph)
		out << "}\n";
	return out.str();
}
