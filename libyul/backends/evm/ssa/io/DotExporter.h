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

#include <cstddef>
#include <optional>
#include <string>

namespace solidity::yul::ssa
{
class SSACFG;
struct ControlFlowGraphs;
namespace analysis
{
class Liveness;
struct ControlFlowGraphsLiveness;
}
}

namespace solidity::yul::ssa::io
{

/// Renders a single SSA CFG in Graphviz dot format, optionally annotated with liveness information.
std::string toDot(
	SSACFG const& _cfg,
	bool _includeDiGraphDefinition = true,
	std::optional<std::size_t> _functionIndex = std::nullopt,
	analysis::Liveness const* _liveness = nullptr,
	ControlFlowGraphs const* _controlFlow = nullptr
);

/// Renders all function graphs in Graphviz dot format, optionally annotated with liveness information.
std::string toDot(
	ControlFlowGraphs const& _controlFlow,
	analysis::ControlFlowGraphsLiveness const* _liveness = nullptr
);

}
