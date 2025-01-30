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

#include <liblangutil/SourceReferenceFormatter.h>
#include <libsolutil/Common.h>

#include <test/libsolidity/util/compiler/Compiler.h>

using namespace solidity::langutil;

namespace solidity::frontend::test
{

using MappedContracts = std::map<std::string, std::vector<CompiledContract>>;
using Errors = ErrorList;

/**
 * Abstraction of the internal compiler aka. `CompilerStack`.
 */
class InternalCompiler
{
public:
	/// Configures and compiles using the internal compiler stack.
	/// @param _input the compiler input with sources, options etc. optionally
	/// set.
	/// @returns the aggregated compiler output.
	CompilerOutput compile(CompilerInput const& _input);

private:
 	/// Configures the compiler stack. Needs to be called before compilation.
	/// @param _input is mapped to the compiler stacks' setters.
	void configure(CompilerInput const& _input);

	/// Compile with cucrrent configuration.
	/// @returns compiled contracts per source unit and possible errors.
	std::pair<MappedContracts, Errors> compile();

	/// @returns `true` if compilation was successful and `false` otherwise. 
	bool success() const;

	/// @returns annotated event signatures per contract.
	/// @param _contractName defines the contract to be used.
	std::vector<AnnotatedEventSignature> generateEventSignatures(
		std::string const& _contractName
	) const;

	/// @returns a formatted output of all errors that occured during
	/// compilation.
	std::string formatErrorInformation() const;

	/// The compiler stack
	CompilerStack m_stack;
};

}
