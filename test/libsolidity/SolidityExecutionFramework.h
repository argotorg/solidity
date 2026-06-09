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
/**
 * @author Christian <c@ethdev.com>
 * @date 2014
 * Framework for executing Solidity contracts and testing them against C++ implementation.
 */

#pragma once

#include <functional>

#include <libsolidity/interface/DebugSettings.h>
#include <libsolidity/interface/StandardJSONInput.h>
#include <libyul/YulStack.h>

#include <ostream>
#include <test/ExecutionFramework.h>
#include <test/libsolidity/util/StandardJSONOutput.h>
#include <test/libsolidity/util/StandardJSONOutputExt.h>
#include <test/libsolidity/util/StandardJSONCompiler.h>

namespace solidity::frontend::test
{

using namespace solidity::test;

class SolidityExecutionFramework: public ExecutionFramework
{

public:
	SolidityExecutionFramework():
		m_showMetadata(CommonOptions::get().showMetadata)
	{
		auto externalCompiler = CommonOptions::get().solcPath;
		if (externalCompiler)
			m_compiler = StandardJSONCompiler<StandardJSONOutputExt>{*externalCompiler};
	}

	explicit SolidityExecutionFramework(
		langutil::EVMVersion _evmVersion,
		std::vector<boost::filesystem::path> const& _vmPaths,
		bool _appendCBORMetadata = true
	):
		ExecutionFramework(_evmVersion, _vmPaths),
		m_showMetadata(CommonOptions::get().showMetadata),
		m_appendCBORMetadata(_appendCBORMetadata)
	{
		auto externalCompiler = CommonOptions::get().solcPath;
		if (externalCompiler)
			m_compiler = StandardJSONCompiler<StandardJSONOutputExt>{*externalCompiler};
	}

	bytes const& compileAndRunWithoutCheck(
		std::map<std::string, std::string> const& _sourceCode,
		u256 const& _value = 0,
		std::string const& _contractName = "",
		bytes const& _arguments = {},
		std::map<std::string, Address> const& _libraryAddresses = {},
		std::optional<std::string> const& _mainSourceName = std::nullopt
	) override
	{
		bytes bytecode = multiSourceCompileContract(_sourceCode, _contractName, _libraryAddresses, _mainSourceName);
		sendMessage(bytecode, _arguments, true, _value);
		return m_output;
	}

	bytes compileContract(
		std::string const& _sourceCode,
		std::string const& _contractName = "",
		std::map<std::string, Address> const& _libraryAddresses = {}
	);

	bytes multiSourceCompileContract(
		std::map<std::string, std::string> const& _sources,
		std::string const& _contractName = "",
		std::map<std::string, Address> const& _libraryAddresses = {},
		std::optional<std::string> const& _mainSourceName = std::nullopt
	);

protected:
	StandardJSONInput m_compilerInput;
	StandardJSONCompiler<StandardJSONOutputExt> m_compiler;
	bool m_compileViaYul = false;
	bool m_compileViaSSACFG = false;
	bool m_showMetadata = false;
	bool m_appendCBORMetadata = true;
	MetadataHash m_metadataHash = MetadataHash::IPFS;
	RevertStrings m_revertStrings = RevertStrings::Default;
};

} // end namespaces
