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

#include <libyul/backends/evm/ssa/LivenessAnalysis.h>
#include <libyul/backends/evm/ssa/SSACFG.h>

#include <libyul/AST.h>
#include <libyul/Scope.h>

#include <range/v3/algorithm/find_if.hpp>

namespace solidity::yul::ssa
{

struct ControlFlow;

struct ControlFlowLiveness{
	explicit ControlFlowLiveness(ControlFlow const& _controlFlow);

	std::reference_wrapper<ControlFlow const> controlFlow;
	std::vector<std::unique_ptr<LivenessAnalysis>> cfgLiveness;

	std::string toDot() const;
};

struct ControlFlow
{
	using FunctionGraphID = std::uint32_t;

	static FunctionGraphID constexpr mainGraphID() noexcept { return 0; }

	SSACFG const* mainGraph() const { return functionGraph(mainGraphID()); }

	SSACFG const* functionGraph(Scope::Function const* _function) const
	{
		auto it = ranges::find_if(functionGraphMapping, [_function](auto const& tup) { return _function == std::get<0>(tup); });
		if (it != functionGraphMapping.end())
			return std::get<1>(*it);
		return nullptr;
	}

	SSACFG const* functionGraph(FunctionGraphID const _id) const
	{
		return functionGraphs.at(_id).get();
	}

	std::string toDot(ControlFlowLiveness const* _liveness=nullptr) const
	{
		if (_liveness)
			yulAssert(&_liveness->controlFlow.get() == this);
		std::ostringstream output;
		output << "digraph SSACFG {\nnodesep=0.7;\ngraph[fontname=\"DejaVu Sans\"]\nnode[shape=box,fontname=\"DejaVu Sans\"];\n\n";

		for (size_t index=0; index < functionGraphs.size(); ++index)
			output << functionGraphs[index]->toDot(
				false,
				index,
				_liveness ? _liveness->cfgLiveness[index].get() : nullptr
			);

		output << "}\n";
		return output.str();
	}

	std::vector<std::unique_ptr<SSACFG>> functionGraphs{};
	std::vector<std::tuple<Scope::Function const*, SSACFG const*>> functionGraphMapping{};
};

}
