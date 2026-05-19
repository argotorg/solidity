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

#include <libyul/backends/evm/ssa/SSACFGTypes.h>

#include <libyul/backends/evm/ssa/SSACFG.h>

using namespace solidity::yul::ssa;

std::string InstId::str(SSACFG const& _cfg) const
{
	if (!hasValue())
		return "INVALID";
	switch (_cfg.kindOf(*this))
	{
	case InstOpcode::Const:
		return toCompactHexWithPrefix(_cfg.literalPayload(*this));
	case InstOpcode::BuiltinCall:
	case InstOpcode::Call:
	case InstOpcode::FunctionArg:
	case InstOpcode::Projection:
	case InstOpcode::Identity:
	case InstOpcode::MemoryGuard:
		return fmt::format("v{}", value);
	case InstOpcode::Phi:
		return fmt::format("phi{}", value);
	case InstOpcode::Unreachable:
		return "[unreachable]";
	case InstOpcode::Upsilon:
	case InstOpcode::Nop:
	case InstOpcode::Tombstone:
		yulAssert(false, "Inst has no output value");
	}
	solidity::util::unreachable();
}
