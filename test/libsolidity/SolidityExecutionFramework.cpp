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

#include "libsolidity/util/StandardJSONOutput.h"
#include <test/libsolidity/SolidityExecutionFramework.h>
#include <test/libsolidity/util/Common.h>
#include <test/libsolidity/util/StandardJSONCompiler.h>
#include <test/libsolidity/util/SoltestErrors.h>

#include <liblangutil/DebugInfoSelection.h>
#include <liblangutil/Exceptions.h>
#include <liblangutil/SourceReferenceFormatter.h>
#include <libyul/Exceptions.h>
#include <libsolidity/interface/StandardJSONInput.h>

#include <boost/test/framework.hpp>

#include <range/v3/algorithm.hpp>
#include <range/v3/algorithm/find_if.hpp>
#include <range/v3/view/filter.hpp>
#include <range/v3/view/transform.hpp>

#include <iostream>
#include <memory>
#include <optional>

using namespace solidity;
using namespace solidity::frontend;
using namespace solidity::frontend::test;
using namespace solidity::langutil;

namespace
{
	std::shared_ptr<const langutil::Error> convertError(output::Error const& _error)
	{
		return std::make_shared<const langutil::Error>(_error.toInternalError());
	}

	std::map<std::string, std::string> convertLibraryAddresses(std::map<std::string, Address> const& _addresses)
	{
		return _addresses | ranges::views::transform([](auto const& entry) {
			auto const& [libraryName, address] = entry;
			auto parts = libraryName | ranges::views::split(':') | ranges::to<std::vector<std::string>>();
			return std::pair{parts.back(), "0x" + address.hex()};
		}) | ranges::to<std::map>();
	}

	Optimizer buildOptimizerSettings(OptimiserSettings const& _settings)
	{
		return Optimizer{
			.enable = false,
			.runs = _settings.expectedExecutionsPerDeployment,
			.details = OptimizerDetails{
				.peephole = _settings.runPeephole,
				.inliner = _settings.runInliner,
				.jumpdestRemover = _settings.runJumpdestRemover,
				.orderLiterals = _settings.runOrderLiterals,
				.deduplicate = _settings.runDeduplicate,
				.cse = _settings.runCSE,
				.constantOptimizer = _settings.runConstantOptimiser,
				.simpleCounterForLoopUncheckedIncrement = _settings.simpleCounterForLoopUncheckedIncrement,
				.yul = _settings.runYulOptimiser,
				.yulDetails = YulOptimizerDetails{
					.stackAllocation = _settings.optimizeStackAllocation,
					.optimizerSteps = _settings.yulOptimiserSteps,
				}
			}
		};
	}

	Metadata buildMetadataSettings(bool _appendCBOR, MetadataHash const& _metadataHash)
	{
		if (_appendCBOR)
			return Metadata{.appendCBOR = _appendCBOR, .bytecodeHash = _metadataHash};
		else
			return Metadata{.appendCBOR = _appendCBOR};
	}
}

bytes SolidityExecutionFramework::multiSourceCompileContract(
	std::map<std::string, std::string> const& _sourceCode,
	std::string const& _contractName,
	std::map<std::string, Address> const& _libraryAddresses,
	std::optional<std::string> const& _mainSourceName
)
{
	if (_mainSourceName.has_value())
		solAssert(_sourceCode.find(_mainSourceName.value()) != _sourceCode.end(), "");

	auto sourceContents = withPreamble(
		_sourceCode,
		solidity::test::CommonOptions::get().useABIEncoderV1 // _addAbicoderV1Pragma
	);
	auto sources = sourceContents | ranges::views::transform([&](auto const& source) {
		return std::pair{source.first, input::Source{.content = source.second}};
	}) | ranges::to<std::map>();
	auto libraries = sources | ranges::views::transform([&](auto const& source) {
		return std::pair{source.first, convertLibraryAddresses(_libraryAddresses)};
	}) | ranges::to<std::map>();

	m_compilerInput = StandardJSONInput{
		.sources = sources,
		.settings = Settings{
			.optimizer = buildOptimizerSettings(m_optimiserSettings),
			.evmVersion = m_evmVersion,
			.viaIR = m_compileViaYul,
			.debug = Debug{
				.revertStrings = m_revertStrings
			},
			.metadata = buildMetadataSettings(m_appendCBORMetadata, m_metadataHash),
			.libraries = libraries,
			.outputSelection = OutputSelection{{{"*", {{"*", {
				"abi",
				"evm.bytecode.object",
				"evm.bytecode.linkReferences",
				"evm.methodIdentifiers",
				"evm.gasEstimates",
				"metadata"
			}}}}}},
		}
	};
	StandardJSONOutputExt const& output = m_compiler.compile(m_compilerInput);

	if (!output.success())
	{
		// The testing framework expects an exception for "unimplemented" yul IR generation.
		auto codeGenError = ranges::find_if(output.errors(), [](auto const& e) {
			return e.type == langutil::Error::Type::CodeGenerationError;
		});

		if (m_compileViaYul && codeGenError != output.errors().end())
			BOOST_THROW_EXCEPTION(*convertError(*codeGenError));

		auto errors = output.errors() | ranges::views::transform(convertError) | ranges::to<langutil::ErrorList>();
		for (auto const& [name, code]: m_compilerInput.sources)
			fmt::print("\n{}\n", SourceReferenceFormatter::formatErrorInformation(
				errors,
				SingletonCharStreamProvider{CharStream{code.content.value_or(""), name}},
				true,
				false
			));

		BOOST_ERROR("Compiling contract failed");
	}

	// Construct `ContractName` with the contract name given, and use `_mainSourceName`
	// if the contract's name source prefix is empty. If the contract name is empty, we allow
	// the output to only define a single contract that does not need to be looked up by name.
	auto const [sourceName, contractName, _] = decomposeContractName(_contractName);
	ContractName lookupName{
		sourceName.empty() ? _mainSourceName.value_or("") : sourceName,
		contractName
	};

	auto const* contract = output.contract(lookupName);
	soltestAssert(contract);
	soltestAssert(contract->evm.bytecode.linkReferences.empty());

	if (m_showMetadata)
		std::cout << "metadata: " << contract->metadata << std::endl;

	return contract->evm.bytecode.object;
}

bytes SolidityExecutionFramework::compileContract(
	std::string const& _sourceCode,
	std::string const& _contractName,
	std::map<std::string, Address> const& _libraryAddresses
)
{
	return multiSourceCompileContract(
		{{"", _sourceCode}},
		_contractName,
		_libraryAddresses,
		std::nullopt
	);
}
