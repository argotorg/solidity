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

/// Utilities shared by multiple libsolidity tests.
#pragma once

#include <libsolidity/interface/CompilerStack.h>

#include <string>

namespace solidity::frontend::test
{

/// @returns @p _sourceCode prefixed with the version pragma and the SPDX license identifier.
/// Can optionally also insert an abicoder pragma when missing.
std::string withPreamble(std::string const& _sourceCode, bool _addAbicoderV1Pragma = false);

/// @returns a copy of @p _sources with preamble prepended to all sources.
StringMap withPreamble(StringMap _sources, bool _addAbicoderV1Pragma = false);

std::string stripPreReleaseWarning(std::string const& _stderrContent);

/// @returns the decomposed parts of a contract name (source and contract, as well as flag
/// that indicates if @param _name was unqualified)
std::tuple<std::string, std::string, bool> decomposeContractName(std::string_view const _name);

/**
 * Helper for contract lookups. A `ContractName` can be initialized from
 * either an unqualified contract name like "C" or a qualified name
 * like ":C" or "lib.sol:C".
 */
class ContractName
{
public:
	/// Construct an empty, unqualified contract name
	ContractName(): m_isUnqualified(true) {}

	/// Construct a fully-qualified contract name.
	/// @param _source the source name
	/// @param _contract the contract name
	ContractName(std::string _source, std::string _contract):
		m_source(std::move(_source)),
		m_contract(std::move(_contract)),
		m_isUnqualified(false)
	{}

	/// Support implicit conversion from e.g. string literals.
	template<typename T>
	requires std::is_convertible_v<T, std::string_view>
	ContractName(T const& _name)
	{
		auto const [source, contract, isUnqualified] = decomposeContractName(_name);
		m_source = source;
		m_contract = contract;
		m_isUnqualified = isUnqualified;
	}

	/// @returns true, if either the unqualified or the fully-qualified name matches.
	bool operator==(ContractName const& _other) const
	{
		auto otherContract = std::string{_other.contract()};
		auto otherSource = std::string{_other.source()};

		return m_contract == otherContract ||
			m_source + ":" + m_contract == otherSource + ":" + otherContract;
	}

	/// @returns the source name.
	std::string_view const source() const
	{
		return m_source;
	}

	/// @returns the contractname.
	std::string_view const contract() const
	{
		return m_contract;
	}

	/// @returns false if this was initialized from an unqualified contract
	/// name like "C".
	bool isUnqualified() const
	{
		return m_isUnqualified;
	}

private:
	/// The source name. Can be empty.
	std::string m_source;
	/// The contract name. Can be empty.
	std::string m_contract;
	/// True, if this is an unqualified contract name.
	bool m_isUnqualified;
};

} // namespace solidity::frontend::test
