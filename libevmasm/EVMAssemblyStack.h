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

#include <libevmasm/AbstractAssemblyStack.h>
#include <libevmasm/Assembly.h>
#include <libevmasm/LinkerObject.h>

#include <libsolutil/JSON.h>

#include <map>
#include <string>
#include <utility>

namespace solidity::evmasm
{

class EVMAssemblyStack: public AbstractAssemblyStack
{
public:
	explicit EVMAssemblyStack(
		langutil::EVMVersion _evmVersion,
		std::optional<uint8_t> _eofVersion,
		Assembly::OptimiserSettings _optimiserSettings
	):
		m_evmVersion(_evmVersion),
		m_eofVersion(_eofVersion),
		m_optimiserSettings(std::move(_optimiserSettings))
	{}

	/// Runs parsing and analysis steps.
	/// Multiple calls overwrite the previous state.
	/// @throws AssemblyImportException, if JSON could not be validated.
	void parseAndAnalyze(std::string const& _sourceName, std::string const& _source);

	/// Runs analysis steps.
	/// Multiple calls overwrite the previous state.
	/// @throws AssemblyImportException, if JSON could not be validated.
	void analyze(std::string const& _sourceName, Json const& _assemblyJson);

	void assemble();

	std::string const& name() const { return m_name; }

	LinkerObject const& object() const { return m_object; }
	LinkerObject const& object(std::string const& _contractName) const override;
	LinkerObject const& runtimeObject() const { return m_runtimeObject; }
	LinkerObject const& runtimeObject(std::string const& _contractName) const override;

	std::shared_ptr<evmasm::Assembly> const& evmAssembly() const { return m_evmAssembly; }
	std::shared_ptr<evmasm::Assembly> const& evmRuntimeAssembly() const { return m_evmRuntimeAssembly; }

	std::string const& sourceMapping() const { return m_sourceMapping; }
	std::string const* sourceMapping(std::string const& _contractName) const override;
	std::string const& runtimeSourceMapping() const { return m_runtimeSourceMapping; }
	std::string const* runtimeSourceMapping(std::string const& _contractName) const override;

	Json ethdebug(std::string const& _contractName) const override;
	Json ethdebugRuntime(std::string const& _contractName) const override;
	Json ethdebug() const override;

	Json assemblyJSON() const;
	Json assemblyJSON(std::string const& _contractName) const override;
	std::string assemblyString(StringMap const& _sourceCodes) const;
	std::string assemblyString(std::string const& _contractName, StringMap const& _sourceCodes) const override;

	std::string const filesystemFriendlyName(std::string const& _contractName) const override;

	std::vector<std::string> contractNames() const override { return {m_name}; }
	std::vector<std::string> sourceNames() const override;
	std::map<std::string, unsigned> sourceIndices() const;

	bool compilationSuccessful() const override { return m_evmAssembly != nullptr; }

	void selectDebugInfo(langutil::DebugInfoSelection _debugInfoSelection)
	{
		m_debugInfoSelection = _debugInfoSelection;
	}

private:
	langutil::EVMVersion m_evmVersion;
	std::optional<uint8_t> m_eofVersion;
	Assembly::OptimiserSettings m_optimiserSettings;
	std::string m_name;
	std::shared_ptr<evmasm::Assembly> m_evmAssembly;
	std::shared_ptr<evmasm::Assembly> m_evmRuntimeAssembly;
	evmasm::LinkerObject m_object; ///< Deployment object (includes the runtime sub-object).
	evmasm::LinkerObject m_runtimeObject; ///< Runtime object.
	std::vector<std::string> m_sourceList;
	langutil::DebugInfoSelection m_debugInfoSelection = langutil::DebugInfoSelection::Default();
	std::string m_sourceMapping;
	std::string m_runtimeSourceMapping;
	std::unique_ptr<Json> m_ethdebug;
	std::unique_ptr<Json> m_ethdebugRuntime;
};

} // namespace solidity::evmasm
