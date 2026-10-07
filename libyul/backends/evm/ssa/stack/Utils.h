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

#include <libyul/backends/evm/ssa/stack/PhiInverse.h>
#include <libyul/backends/evm/ssa/stack/ShuffleTrace.h>
#include <libyul/backends/evm/ssa/stack/Stack.h>

#include <string>
#include <vector>

namespace solidity::yul::ssa::stack
{

class ValidationResult
{
public:
	bool ok() const { return m_errors.empty(); }
	std::string formatErrors() const;
	ValidationResult& addError(std::string _msg) { m_errors.push_back(std::move(_msg)); return *this; }
	std::vector<std::string> const& errors() const { return m_errors; }
private:
	std::vector<std::string> m_errors;
};

/// Computes the EVM gas cost of executing `_trace`.
std::size_t stackOpsGas(SSACFG const& _cfg, ShuffleTrace const& _trace);

/// Transform stack data by replacing all its phi variables with their respective preimages.
Data stackPreImage(SSACFG const& _cfg, Data _stack, PhiInverse const& _phiInverse);

CallSites gatherCallSites(SSACFG const& _cfg);

/// Checks that _current and _desired have the same size and that each slot matches,
/// treating junk slots in _desired as wildcards.
ValidationResult checkLayoutCompatibility(Data const& _current, Data const& _desired);

}
