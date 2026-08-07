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

#include <libsolutil/FixedHash.h>
#include <libsolutil/JSON.h>

#include <liblangutil/EVMVersion.h>
#include <liblangutil/Exceptions.h>

#include <libsolidity/interface/MetadataSettings.h>
#include <libsolidity/interface/DebugSettings.h>
#include <libsolidity/interface/OptimiserSettings.h>

#include <range/v3/algorithm.hpp>
#include <range/v3/view/filter.hpp>
#include <range/v3/view/join.hpp>
#include <range/v3/view/map.hpp>
#include <range/v3/view/split.hpp>
#include <range/v3/view/transform.hpp>
#include <range/v3/range/conversion.hpp>

#include <optional>
#include <vector>

namespace solidity::frontend::input
{

struct YulOptimizerDetails
{
	/// Improve allocation of stack slots for variables, can free up stack slots early.
	/// When omitted: true (if Yul optimizer is enabled).
	std::optional<bool> stackAllocation;
	/// Optimization step sequence. The general form of the value is "<main sequence>:<cleanup sequence>".
	/// If it does not contain the ':' delimiter, it is interpreted as the main
	/// sequence and the default is used for the cleanup sequence.
	/// When omitted: the default optimization sequence.
	std::optional<std::string> optimizerSteps;
};

inline void to_json(Json& _json, YulOptimizerDetails const& _details)
{
	if (_details.stackAllocation)
		_json["stackAllocation"] = *_details.stackAllocation;
	if (_details.optimizerSteps)
		_json["optimizerSteps"] = *_details.optimizerSteps;
}

struct OptimizerDetails
{
	/// Peephole optimizer (opcode-based).
	/// When omitted: true.
	std::optional<bool> peephole = std::nullopt;
	/// Inliner (opcode-based).
	/// When omitted: true (when optimization is enabled).
	std::optional<bool> inliner = std::nullopt;
	/// Unused JUMPDEST remover (opcode-based).
	/// When omitted: true.
	std::optional<bool> jumpdestRemover = std::nullopt;
	/// Literal reordering (codegen-based).
	/// When omitted: true (when optimization is enabled).
	std::optional<bool> orderLiterals = std::nullopt;
	/// Block deduplicator (opcode-based).
	/// When omitted: true (when optimization is enabled).
	std::optional<bool> deduplicate = std::nullopt;
	/// Common subexpression elimination (opcode-based).
	/// When omitted: true (when optimization is enabled).
	std::optional<bool> cse = std::nullopt;
	/// Constant optimizer (opcode-based).
	/// When omitted: true (when optimization is enabled).
	std::optional<bool> constantOptimizer = std::nullopt;
	/// Unchecked loop increment (codegen-based).
	/// When omitted: true.
	std::optional<bool> simpleCounterForLoopUncheckedIncrement = std::nullopt;
	/// Yul optimizer.
	/// When omitted: true (when optimization is enabled).
	std::optional<bool> yul = std::nullopt;
	/// Tuning options for the Yul optimizer.
	std::optional<YulOptimizerDetails> yulDetails = std::nullopt;
};

inline void to_json(Json& _json, OptimizerDetails const& _details)
{
	if (_details.peephole)
		_json["peephole"] = *_details.peephole;
	if (_details.orderLiterals)
		_json["orderLiterals"] = *_details.orderLiterals;
	if (_details.inliner)
		_json["inliner"] = *_details.inliner;
	if (_details.jumpdestRemover)
		_json["jumpdestRemover"] = *_details.jumpdestRemover;
	if (_details.deduplicate)
		_json["deduplicate"] = *_details.deduplicate;
	if (_details.cse)
		_json["cse"] = *_details.cse;
	if (_details.constantOptimizer)
		_json["constantOptimizer"] = *_details.constantOptimizer;
	if (_details.simpleCounterForLoopUncheckedIncrement)
		_json["simpleCounterForLoopUncheckedIncrement"] = *_details.simpleCounterForLoopUncheckedIncrement;
	if (_details.yul)
		_json["yul"] = *_details.yul;
	if (_details.yulDetails && _details.yul && *_details.yul)
		_json["yulDetails"] = *_details.yulDetails;
}

struct Optimizer
{
	/// Turn on the optimizer.
	/// When omitted: false.
	std::optional<bool> enable = std::nullopt;
	/// Optimize for how many times you intend to run the code.
	/// When omitted: 200.
	std::optional<size_t> runs = std::nullopt;
	/// State of all optimizer components.
	std::optional<OptimizerDetails> details = std::nullopt;
};

inline void to_json(Json& _json, Optimizer const& _optimizer)
{
	if (_optimizer.enable)
		_json["enabled"] = *_optimizer.enable;
	if (_optimizer.runs)
		_json["runs"] = *_optimizer.runs;
	if (_optimizer.details)
		_json["details"] = *_optimizer.details;
}

struct Debug
{
	/// How to treat revert (and require) reason strings.
	/// When omitted: RevertStrings::Default.
	std::optional<RevertStrings> revertStrings = std::nullopt;
	/// How much extra debug information to include in comments in the produced
	/// EVM assembly and Yul code. Available components are: location, snippet,
	/// ast-id, ethdebug, and * (wildcard for all non-experimental components).
	/// When omitted: no debug info is requested.
	std::optional<std::vector<std::string>> debugInfo = std::nullopt;
};

inline void to_json(Json& _json, Debug const& _debug)
{
	if (_debug.revertStrings)
		_json["revertStrings"] = revertStringsToString(_debug.revertStrings.value());
	if (_debug.debugInfo)
		_json["debugInfo"] = *_debug.debugInfo;
}

struct Metadata
{
	/// The CBOR metadata is appended at the end of the bytecode by default.
	/// Setting this to false omits the metadata from the runtime and deploy time code.
	/// When omitted: true.
	std::optional<bool> appendCBOR = std::nullopt;
	/// Use the given hash method for the metadata hash that is appended to the bytecode.
	/// When omitted: MetadataHash::IPFS.
	std::optional<MetadataHash> bytecodeHash = std::nullopt;
	/// Use only literal content and not URLs in the metadata.
	/// When omitted: false.
	std::optional<bool> useLiteralContent = std::nullopt;
};

inline void to_json(Json& _json, Metadata const& _metadata)
{
	if (_metadata.appendCBOR)
		_json["appendCBOR"] = *_metadata.appendCBOR;
	if (_metadata.bytecodeHash)
		_json["bytecodeHash"] = metadataHashToString(_metadata.bytecodeHash.value());
	if (_metadata.useLiteralContent)
		_json["useLiteralContent"] = *_metadata.useLiteralContent;
}

/// Model checker settings. The SMTChecker is experimental and subject to changes.
struct ModelChecker
{
	/// Which contracts should be analyzed as the most derived.
	/// Maps source file names to arrays of contract names.
	/// When omitted: all contracts are analyzed.
	std::optional<std::map<std::string, std::vector<std::string>>> contracts = std::nullopt;
	/// Whether division and modulo operations should be replaced by multiplication with slack variables.
	/// When omitted: false.
	std::optional<bool> divModNoSlacks = std::nullopt;
	/// Which model checker engine to use: "all", "bmc", "chc", or "none".
	/// When omitted: no engine is enabled.
	std::optional<std::string> engine = std::nullopt;
	/// Whether external calls should be considered trusted: "trusted" or "untrusted".
	/// When omitted: "untrusted".
	std::optional<std::string> extCalls = std::nullopt;
	/// Which types of invariants should be reported: "contract", "reentrancy".
	/// When omitted: default invariants.
	std::optional<std::vector<std::string>> invariants = std::nullopt;
	/// Whether to output all proved targets. When omitted: false.
	std::optional<bool> showProvedSafe = std::nullopt;
	/// Whether to output all unproved targets. When omitted: false.
	std::optional<bool> showUnproved = std::nullopt;
	/// Whether to output all unsupported language features. When omitted: false.
	std::optional<bool> showUnsupported = std::nullopt;
	/// Which solvers should be used, e.g. "cvc5", "smtlib2", "z3".
	/// When omitted: Z3.
	std::optional<std::vector<std::string>> solvers = std::nullopt;
	/// Which verification targets should be checked: "constantCondition", "underflow",
	/// "overflow", "divByZero", "balance", "assert", "popEmptyArray", "outOfBounds".
	/// When omitted: all targets except underflow/overflow for Solidity >=0.8.7.
	std::optional<std::vector<std::string>> targets = std::nullopt;
	/// Timeout for each SMT query in milliseconds.
	/// When omitted: a deterministic resource limit is used.
	std::optional<unsigned> timeout = std::nullopt;
	/// Number of loop iterations for the BMC engine.
	/// When omitted: no limit. Requires the BMC engine to be enabled.
	std::optional<unsigned> bmcLoopIterations = std::nullopt;
};

inline void to_json(Json& _json, ModelChecker const& _modelChecker)
{
	if (_modelChecker.contracts)
	{
		for (auto const& [source, contracts]: *_modelChecker.contracts)
			_json["contracts"][source] = contracts;
	}
	if (_modelChecker.divModNoSlacks)
		_json["divModNoSlacks"] = *_modelChecker.divModNoSlacks;
	if (_modelChecker.engine)
		_json["engine"] = *_modelChecker.engine;
	if (_modelChecker.extCalls)
		_json["extCalls"] = *_modelChecker.extCalls;
	if (_modelChecker.invariants)
		_json["invariants"] = *_modelChecker.invariants;
	if (_modelChecker.showProvedSafe)
		_json["showProvedSafe"] = *_modelChecker.showProvedSafe;
	if (_modelChecker.showUnproved)
		_json["showUnproved"] = *_modelChecker.showUnproved;
	if (_modelChecker.showUnsupported)
		_json["showUnsupported"] = *_modelChecker.showUnsupported;
	if (_modelChecker.solvers)
		_json["solvers"] = *_modelChecker.solvers;
	if (_modelChecker.targets)
		_json["targets"] = *_modelChecker.targets;
	if (_modelChecker.timeout)
		_json["timeout"] = *_modelChecker.timeout;
	if (_modelChecker.bmcLoopIterations)
		_json["bmcLoopIterations"] = *_modelChecker.bmcLoopIterations;
}

using LibraryAddresses = std::map<std::string, std::map<std::string, std::string>>;
using OutputSelection = std::map<std::string, std::map<std::string, std::vector<std::string>>>;

struct Settings
{
	/// Stop compilation after the given stage. Currently only "parsing" is valid.
	/// When omitted: compilation runs to completion.
	std::optional<std::string> stopAfter = std::nullopt;
	/// List of import remappings, e.g. "g=/dir/".
	/// When omitted: no remappings.
	std::optional<std::vector<std::string>> remappings = std::nullopt;
	/// Experimental mode toggle.
	/// When omitted: false.
	std::optional<bool> experimental = std::nullopt;
	/// The optimizer settings.
	std::optional<Optimizer> optimizer = std::nullopt;
	/// Version of the EVM to compile for.
	std::optional<langutil::EVMVersion> evmVersion = std::nullopt;
	/// Change compilation pipeline to go through the Yul intermediate representation.
	/// When omitted: false.
	std::optional<bool> viaIR = std::nullopt;
	/// Turn on SSA CFG-based code generation via the IR (experimental, implies viaIR: true).
	/// When omitted: false.
	std::optional<bool> viaSSACFG = std::nullopt;
	/// Debugging settings.
	std::optional<Debug> debug = std::nullopt;
	/// Metadata settings.
	std::optional<Metadata> metadata = std::nullopt;
	/// Information on which library is deployed where. Addresses need 0x-prefix.
	std::optional<LibraryAddresses> libraries = std::nullopt;
	/// Output selection per source file and contract.
	/// The first level key is the file name (or "*" for all files).
	/// The second level key is the contract name (or "*" for all contracts, "" for file-level outputs).
	/// When omitted: no outputs are requested.
	std::optional<OutputSelection> outputSelection = std::nullopt;
	/// Model checker settings. The SMTChecker is experimental and subject to changes.
	std::optional<ModelChecker> modelChecker = std::nullopt;

};

inline void to_json(Json& _json, Settings const& _settings)
{
	if (_settings.stopAfter)
		_json["stopAfter"] = *_settings.stopAfter;
	if (_settings.remappings)
		_json["remappings"] = *_settings.remappings;
	if (_settings.experimental)
		_json["experimental"] = *_settings.experimental;
	if (_settings.optimizer)
		_json["optimizer"] = *_settings.optimizer;
	if (_settings.evmVersion)
		_json["evmVersion"] = (*_settings.evmVersion).name();
	if (_settings.viaIR)
		_json["viaIR"] = *_settings.viaIR;
	if (_settings.viaSSACFG)
		_json["viaSSACFG"] = *_settings.viaSSACFG;
	if (_settings.debug)
		_json["debug"] = *_settings.debug;
	if (_settings.metadata)
		_json["metadata"] = *_settings.metadata;
	if (_settings.libraries)
		_json["libraries"] = *_settings.libraries;
	if (_settings.modelChecker)
		_json["modelChecker"] = *_settings.modelChecker;
	if (_settings.outputSelection)
		_json["outputSelection"] = *_settings.outputSelection;
}

struct Source
{
	/// Required (unless "urls" is used): literal contents of the source file.
	std::optional<std::string> content = std::nullopt;
	/// Keccak256 hash of the source file, used to verify retrieved content.
	std::optional<std::string> keccak256 = std::nullopt;
	/// URLs of the source file, imported in order.
	std::optional<std::vector<std::string>> urls = std::nullopt;
};

inline void to_json(Json& _json, Source const& _source)
{
	if (_source.content)
		_json["content"] = *_source.content;
	if (_source.keccak256)
		_json["keccak256"] = *_source.keccak256;
	if (_source.urls)
		_json["urls"] = *_source.urls;
}

/**
 * The input the compiler is requested to compile with. It carries source and
 * compiler configuration.
 */
struct StandardJSONInput
{
	/// The language of the input, e.g. "Solidity" or "Yul".
	std::string language = "Solidity";
	/// Source files to compile, keyed by global name.
	std::map<std::string, Source> sources = {};
	/// The compiler settings, e.g. EVM version, optimizer settings and Yul config.
	std::optional<input::Settings> settings = std::nullopt;
};

inline void to_json(Json& _json, StandardJSONInput const& _input)
{
	_json["language"] = _input.language;

	for (auto& [name, source] : _input.sources)
		_json["sources"][name] = source;

	if (_input.settings)
		_json["settings"] = *_input.settings;
}

}
