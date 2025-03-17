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
 * @date 2016
 * Framework for executing Solidity contracts and testing them against C++ implementation.
 */

#include <test/libsolidity/SolidityExecutionFramework.h>
#include <test/libsolidity/util/Common.h>
#include <test/libsolidity/util/SoltestErrors.h>

#include <liblangutil/DebugInfoSelection.h>
#include <libyul/Exceptions.h>
#include <liblangutil/Exceptions.h>
#include <liblangutil/SourceReferenceFormatter.h>

#include <boost/test/framework.hpp>

#include <cstdlib>
#include <iostream>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::frontend::test;
using namespace solidity::langutil;
using namespace solidity::test;

bytes SolidityExecutionFramework::multiSourceCompileContract(
	std::map<std::string, std::string> const& _sourceCode,
	std::optional<std::string> const& _mainSourceName,
	std::string const& _contractName,
	std::map<std::string, Address> const& _libraryAddresses
)
{
	std::cout << "multiSourceCompileContract():" << std::endl;
	std::cout << "_contractName: " << _contractName << std::endl;

	if (_mainSourceName.has_value())
		solAssert(_sourceCode.find(_mainSourceName.value()) != _sourceCode.end(), "");

	m_compilerInput = CompilerInput{};
	m_compilerInput.sourceCode = withPreamble(
		_sourceCode,
		solidity::test::CommonOptions::get().useABIEncoderV1 // _addAbicoderV1Pragma
	);
	m_compilerInput.libraryAddresses = _libraryAddresses;
	m_compilerInput.evmVersion = std::make_optional(m_evmVersion);
	m_compilerInput.eofVersion = m_eofVersion;
	m_compilerInput.optimiserSettings = std::make_optional(m_optimiserSettings);
	m_compilerInput.revertStrings = std::make_optional(m_revertStrings);
	m_compilerInput.metadataHash = std::make_optional(m_metadataHash);
	m_compilerInput.viaIR = std::make_optional(m_compileViaYul);
	if (!m_appendCBORMetadata) {
		m_compilerInput.metadataFormat = std::make_optional(MetadataFormat::NoMetadata);
	}

	m_compiler.compile(m_compilerInput);

	auto output = m_compiler.output();

	std::cout << output << std::endl;

	if (!output.success())
	{
		// The testing framework expects an exception for
		// "unimplemented" yul IR generation.
		if (m_compileViaYul)
		{
			auto type = langutil::Error::Type::CodeGenerationError;
			auto error = output.findError(type);
			if (error.has_value())
				BOOST_THROW_EXCEPTION(error.value());
		}
		std::cout << output.errorInformation() << std::endl;
		BOOST_ERROR("Compiling contract failed");
	}

	std::optional<CompiledContract> contract;
	if (_contractName.empty())
		contract = output.contract(_mainSourceName, std::nullopt);
	else
		contract = output.contract(std::nullopt, std::make_optional(_contractName));

	soltestAssert(contract.has_value());
	soltestAssert(!contract.value().hasUnlinkedReferences);
	
	if (m_showMetadata)
		std::cout << "metadata: " << contract.value().metadata << std::endl;

	std::cout << "_contract.name: " << contract.value().name << std::endl;
	return contract.value().object;
}

bytes SolidityExecutionFramework::compileContract(
	std::string const& _sourceCode,
	std::string const& _contractName,
	std::map<std::string, Address> const& _libraryAddresses
)
{
	return multiSourceCompileContract(
		{{"", _sourceCode}},
		std::nullopt,
		_contractName,
		_libraryAddresses
	);
}
