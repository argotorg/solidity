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

#include <libyul/backends/evm/ssa/ControlFlow.h>
#include <libsolutil/JSON.h>
#include <libsolutil/Visitor.h>

namespace solidity::yul::ssa
{

class SSACFGJsonExporter
{
public:
	SSACFGJsonExporter(ControlFlow const& _controlFlow, ControlFlowLiveness const* _liveness=nullptr);
	Json run();
	Json exportBlock(SSACFG const& _cfg, SSACFG::BlockId _blockId, LivenessAnalysis const* _liveness);
	Json exportFunction(SSACFG const& _cfg, LivenessAnalysis const* _liveness);
	std::string varToString(SSACFG const& _cfg, SSACFG::ValueId _var);

private:
	ControlFlow const& m_controlFlow;
	ControlFlowLiveness const* m_liveness;
	Json toJson(SSACFG const& _cfg, SSACFG::BlockId _blockId, LivenessAnalysis const* _liveness);
	Json toJson(Json& _ret, SSACFG const& _cfg, SSACFG::Operation const& _operation);
	Json toJson(SSACFG const& _cfg, std::vector<SSACFG::ValueId> const& _values);
};

}
