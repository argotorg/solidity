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

#include <test/libsolidity/util/Common.h>
#include <test/libsolidity/util/StandardJSONOutput.h>

#include <vector>

namespace solidity::frontend::test
{

using namespace output;

/**
 * Wraps a StandardJSONOutput with convenience accessors for the test framework.
 */
class StandardJSONOutputExt
{
public:
	explicit StandardJSONOutputExt(StandardJSONOutput _base):
		m_base(std::move(_base))
	{}

	/// @returns true if no errors or only warnings/info messages were produced.
	bool success() const;

	/// @returns all errors (including warnings and infos) from the compilation.
	std::vector<Error> const& errors() const;

	/// @returns Collected pointers to all contracts across all source units.
	std::vector<Contract const*> const contracts() const;

	/// Looks up a contract by its (optionally source-qualified) name.
	/// If the name is empty, asserts that there is exactly one contract across
	/// all source units and returns it.
	/// @returns the contract, or nullptr if not found.
	Contract const* contract(ContractName const& _contractName = {}) const;

private:
	/// The wrapped compiler output.
	StandardJSONOutput m_base;
};

}
