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

#pragma once

#include <libyul/backends/evm/ssa/SSACFG.h>

#include <fmt/format.h>

#include <optional>
#include <string>
#include <utility>
#include <vector>

namespace solidity::yul::ssa::io
{

/// Base class for exporting an SSACFG to Graphviz dot format.
/// Handles graph structure (BFS traversal, edges, exit nodes, entry nodes) and
/// delegates block content rendering to derived classes via writeBlockLabel().
class DotExporterBase
{
public:
	enum class EdgeStyle { Solid, Dashed };
	enum class RankDir { TB, BT, LR, RL };

	DotExporterBase(SSACFG const& _cfg, size_t _functionIndex, RankDir _rankDir = RankDir::LR);
	virtual ~DotExporterBase() = default;

	std::string exportBlocks(SSACFG::BlockId _entry, bool _wrapInDigraph = true);
	std::string exportFunction(Scope::Function const& _function, bool _wrapInDigraph = true);

protected:
	/// Override to write the content inside a block's dot label.
	/// Everything between the opening `label="` and the closing `"` is the responsibility of this method.
	virtual void writeBlockLabel(std::ostream& _out, SSACFG::BlockId _blockId) = 0;

	/// Override to provide extra node attributes (e.g., fillcolor).
	virtual std::vector<std::pair<std::string, std::string>> blockNodeAttributes(SSACFG::BlockId) { return {}; }

	/// Override to customize edge style (e.g., dashed for back edges).
	virtual EdgeStyle edgeStyle(SSACFG::BlockId, SSACFG::BlockId) { return EdgeStyle::Solid; }

	std::string formatBlockHandle(SSACFG::BlockId _id) const;
	/// Escapes a string for use in dot node IDs (replaces non-alphanumeric characters with underscores).
	static std::string escapeId(std::string_view _str);
	/// Escapes a string for use inside dot label text (escapes quotes and backslashes).
	static std::string escapeLabel(std::string_view _str);

	SSACFG const& m_cfg;
	size_t m_functionIndex;
	RankDir m_rankDir;

private:
	void writeBlock(std::ostream& _out, SSACFG::BlockId _id);
	std::string formatEdge(SSACFG::BlockId _source, SSACFG::BlockId _target, std::optional<std::string> const& _exitPort = std::nullopt);
	void traverse(std::ostream& _out, SSACFG::BlockId _entry);
};

}

template<>
struct fmt::formatter<solidity::yul::ssa::io::DotExporterBase::RankDir>: fmt::formatter<std::string_view>
{
	auto format(solidity::yul::ssa::io::DotExporterBase::RankDir _rankDir, fmt::format_context& _ctx) const
	{
		using RankDir = solidity::yul::ssa::io::DotExporterBase::RankDir;
		std::string_view name;
		switch (_rankDir)
		{
			case RankDir::TB: name = "TB"; break;
			case RankDir::BT: name = "BT"; break;
			case RankDir::LR: name = "LR"; break;
			case RankDir::RL: name = "RL"; break;
		}
		return fmt::formatter<std::string_view>::format(name, _ctx);
	}
};
