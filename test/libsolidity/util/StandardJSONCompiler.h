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

#include <test/libsolidity/util/StandardJSONCompilerAdapter.h>
#include <test/libsolidity/util/StandardJSONOutput.h>

#include <liblangutil/Exceptions.h>
#include <libsolidity/interface/StandardJSONInput.h>
#include <libsolidity/util/SoltestErrors.h>

#include <optional>
#include <variant>

namespace solidity::frontend::test
{

using namespace solidity::frontend::input;
using namespace output;

template<typename T>
concept StandardJSONOutputType = std::constructible_from<T, StandardJSONOutput>;

/**
 * Provides an interface to the compiler under test.
 *
 * Delegates to either an InternalCompilerAdapter (in-process) or an ExternalCompilerAdapter
 * (external solc binary) depending on how it was constructed.
 */
template<StandardJSONOutputType Output = StandardJSONOutput>
class StandardJSONCompiler
{
public:
	/// Creates a compiler that uses the in-process InternalCompilerAdapter.
	static StandardJSONCompiler internal()
	{
		return StandardJSONCompiler{InternalCompilerAdapter{}};
	}

	/// Creates a compiler that uses the ExternalCompilerAdapter with the given path to solc.
	static StandardJSONCompiler ipc([[maybe_unused]] boost::filesystem::path _compilerPath)
	{
		#ifdef _WIN32 // windows
			solUnimplemented("Using external compilers is not supported on Windows.");
		#else // unix
			return StandardJSONCompiler{ExternalCompilerAdapter{std::move(_compilerPath)}};
		#endif
	}

	/// Takes the current compiler input, requests the compiler under test to compile
	/// and stores its output.
	/// @returns the stored output
	/// @param _input to pass to the compiler
	Output const& compile(StandardJSONInput const& _input)
	{
		m_output.emplace(Output{std::visit([&_input](auto& compiler) {
			return compiler.compile(_input);
		}, m_compiler)});
		return this->output();
	}

	/// @returns the stored output generated during previous compilation.
	Output const& output() const
	{
		soltestAssert(m_output.has_value(), "No output found. Please compile first.");
		return m_output.value();
	}

private:
	explicit StandardJSONCompiler(InternalCompilerAdapter _adapter):
		m_compiler(std::move(_adapter))
	{}

	explicit StandardJSONCompiler(ExternalCompilerAdapter _adapter):
		m_compiler(std::move(_adapter))
	{}

	std::variant<InternalCompilerAdapter, ExternalCompilerAdapter> m_compiler;
	std::optional<Output> m_output;
};

}
