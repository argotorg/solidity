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

#include <test/libsolidity/util/StandardJSONOutput.h>
#include <test/libsolidity/util/StandardJSONOutputParser.h>

#include <libsolidity/interface/StandardCompiler.h>
#include <libsolidity/interface/StandardJSONInput.h>
#include <libsolidity/util/SoltestErrors.h>

#include <libsolutil/JSON.h>

#include <boost/asio.hpp>
#include <boost/process/v2.hpp>
#include <boost/process/v2/process.hpp>
#include <boost/process/v2/stdio.hpp>

#include <chrono>
#include <string>

namespace solidity::frontend::test
{

using namespace solidity::frontend::input;
using namespace output;

/**
 * Adapter that delegates compilation to the in-process StandardCompiler.
 */
class InternalCompilerAdapter
{
public:
	InternalCompilerAdapter() = default;

	/// Compiles the given input using the in-process StandardCompiler and
	/// @returns the deserialized StandardJSONOutput.
	StandardJSONOutput compile(StandardJSONInput const& _input)
	{
		Json jsonInput = _input;
		Json jsonOutput = StandardCompiler{}.compile(jsonInput);
		return jsonOutput.get<StandardJSONOutput>();
	}
};

/**
 * Adapter that delegates compilation to a solc-compatible binary via an external process.
 */
class ExternalCompilerAdapter
{
public:
	explicit ExternalCompilerAdapter(
		boost::filesystem::path _path,
		std::chrono::seconds _timeout = std::chrono::seconds{30}
	):
		m_path(std::move(_path)),
		m_timeout(_timeout)
	{}

	/// Compiles the given input by spawning an external compiler process and
	/// communicating via stdin/stdout, then @returns the deserialized StandardJSONOutput.
	StandardJSONOutput compile(StandardJSONInput const& _input)
	{
		namespace bp = boost::process::v2;
		namespace asio = boost::asio;

		auto ioCtx = asio::io_context{};
		auto stdinPipe = asio::writable_pipe{ioCtx};
		auto stdoutPipe = asio::readable_pipe{ioCtx};

		auto spawn = [&]() -> bp::process
		{
			auto child = bp::process{
				ioCtx,
				m_path,
				{"--standard-json"},
				bp::process_stdio{stdinPipe, stdoutPipe, {}}
			};
			soltestAssert(child.running(), "Failed to launch the external compiler '" + m_path.string() + "'.");
			return child;
		};

		auto write = [&](auto& _stdinPipe, StandardJSONInput const& _input) -> void
		{
			auto error = boost::system::error_code{};
			Json input = _input;
			asio::write(_stdinPipe, asio::buffer(input.dump()), error);
			_stdinPipe.close();
			soltestAssert(!error, "Error writing to the external compiler's stdin.");
		};

		auto read = [&](auto& _stdoutPipe, auto& _child) -> std::string
		{
			auto output = std::string{};
			auto error = boost::system::error_code{};
			auto timer = asio::steady_timer{ioCtx, m_timeout};

			asio::async_read(_stdoutPipe, asio::dynamic_buffer(output),
				[&error, &timer](auto const& _errorCode, size_t) {
					error = _errorCode;
					timer.cancel();
				}
			);
			timer.async_wait([&_child, &timer](auto const& _errorCode) {
				if (_errorCode != asio::error::operation_aborted)
				{
					_child.request_exit();
					timer.cancel();
				}
			});
			ioCtx.run();

			if (timer.expiry() <= asio::steady_timer::clock_type::now())
				soltestAssert(false, "External compiler '" + m_path.string() + "' timed out after " + std::to_string(m_timeout.count()) + " seconds.");
			soltestAssert(!error || error == asio::error::eof, "Error reading from the external compiler's stdout.");

			return output;
		};

		auto parse = [&](auto& _child, std::string _output) -> StandardJSONOutput
		{
			_child.wait();
			soltestAssert(
				_child.exit_code() == 0,
				"External compiler exited unexpectedly with code '" + std::to_string(_child.exit_code()) + "'"
			);

			while (!_output.empty() && (_output.back() == '\n' || _output.back() == '\r'))
				_output.pop_back();

			auto parser = output::NlohmannParser{};
			return output::extract<StandardJSONOutput>(parser, _output);
		};

		auto solc = spawn();
		write(stdinPipe, _input);
		auto output = read(stdoutPipe, solc);

		return parse(solc, std::move(output));
	}

private:
	/// Path to the binary that complies to solc's standard JSON input / output behaviour.
	boost::filesystem::path m_path;
	/// Maximum time to wait for the external compiler to respond.
	std::chrono::seconds m_timeout;
};

}
