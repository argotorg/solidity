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
 * Yul dialects for EVM.
 */

#pragma once

#include <libyul/Dialect.h>
#include <libyul/Scope.h>

#include <libyul/backends/evm/AbstractAssembly.h>
#include <libyul/backends/evm/EVMBuiltins.h>

#include <liblangutil/EVMVersion.h>

#include <array>
#include <optional>
#include <set>
#include <unordered_map>
#include <vector>

namespace solidity::yul
{

struct FunctionCall;
class Object;

/**
 * Yul dialect for EVM as a backend.
 * The main difference is that the builtin functions take an AbstractAssembly for the
 * code generation.
 *
 * Builtins are defined so that their handles stay compatible over different dialect flavors - be it with/without
 * object access, with/without EOF, different versions. It may be, of course, that these builtins are no longer defined.
 * The ones that _are_ defined, though, remain under the same handle.
 */
class EVMDialect: public Dialect
{
public:
	/// Handles to (depending on dialect, potentially existing) builtins, which are not accessible via the
	/// `...FunctionHandle` functions of `Dialect` and of which it is statically known, that they are needed in,
	/// e.g., certain optimization steps.
	struct AuxiliaryBuiltinHandles
	{
		std::optional<BuiltinHandle> add;
		std::optional<BuiltinHandle> exp;
		std::optional<BuiltinHandle> mul;
		std::optional<BuiltinHandle> not_;
		std::optional<BuiltinHandle> shl;
		std::optional<BuiltinHandle> sub;
	};
	/// Constructor, should only be used internally. Use the factory functions below.
	EVMDialect(langutil::EVMVersion _evmVersion, std::optional<uint8_t> _eofVersion, bool _objectAccess);

	std::optional<BuiltinHandle> findBuiltin(std::string_view _name) const override;

	BuiltinFunctionForEVM const& builtin(BuiltinHandle const& _handle) const override;

	bool reservedIdentifier(std::string_view _name) const override;

	std::optional<BuiltinHandle> discardFunctionHandle() const override { return m_discardFunction; }
	std::optional<BuiltinHandle> equalityFunctionHandle() const override { return m_equalityFunction; }
	std::optional<BuiltinHandle> booleanNegationFunctionHandle() const override { return m_booleanNegationFunction; }
	std::optional<BuiltinHandle> memoryStoreFunctionHandle() const override { return m_memoryStoreFunction; }
	std::optional<BuiltinHandle> memoryLoadFunctionHandle() const override { return m_memoryLoadFunction; }
	std::optional<BuiltinHandle> storageStoreFunctionHandle() const override { return m_storageStoreFunction; }
	std::optional<BuiltinHandle> storageLoadFunctionHandle() const override { return m_storageLoadFunction; }
	std::optional<BuiltinHandle> hashFunctionHandle() const override { return m_hashFunction; }
	AuxiliaryBuiltinHandles const& auxiliaryBuiltinHandles() const { return m_auxiliaryBuiltinHandles; }

	static EVMDialect const& strictAssemblyForEVM(langutil::EVMVersion _evmVersion, std::optional<uint8_t> _eofVersion);
	/// Builtins with and without object access are compatible, i.e., builtin handles without object access are not
	/// invalidated and still point to the same function.
	static EVMDialect const& strictAssemblyForEVMObjects(langutil::EVMVersion _evmVersion, std::optional<uint8_t> _eofVersion);

	langutil::EVMVersion evmVersion() const { return m_evmVersion; }
	std::optional<uint8_t> eofVersion() const { return m_eofVersion; }
	size_t reachableStackDepth() const { return m_eofVersion.has_value() ? 256 : 16; }

	bool providesObjectAccess() const { return m_objectAccess; }

	static size_t constexpr verbatimMaxInputSlots = 100;
	static size_t constexpr verbatimMaxOutputSlots = 100;

	std::set<std::string_view> builtinFunctionNames() const;

protected:
	static bool constexpr isVerbatimHandle(BuiltinHandle const& _handle) { return _handle.id < verbatimIDOffset; }
	static BuiltinFunctionForEVM createVerbatimFunctionFromHandle(BuiltinHandle const& _handle);
	BuiltinHandle verbatimFunction(size_t _arguments, size_t _returnVariables) const;

	static size_t constexpr verbatimIDOffset = verbatimMaxInputSlots * verbatimMaxOutputSlots;

	static EVMBuiltins const& allBuiltins();

	bool const m_objectAccess;
	langutil::EVMVersion const m_evmVersion;
	std::optional<uint8_t> m_eofVersion;
	std::unordered_map<std::string_view, BuiltinHandle> m_builtinFunctionsByName;
	std::vector<BuiltinFunctionForEVM const*> m_functions;
	std::array<std::unique_ptr<BuiltinFunctionForEVM>, verbatimIDOffset> mutable m_verbatimFunctions{};
	std::set<std::string, std::less<>> m_reserved;

	std::optional<BuiltinHandle> m_discardFunction;
	std::optional<BuiltinHandle> m_equalityFunction;
	std::optional<BuiltinHandle> m_booleanNegationFunction;
	std::optional<BuiltinHandle> m_memoryStoreFunction;
	std::optional<BuiltinHandle> m_memoryLoadFunction;
	std::optional<BuiltinHandle> m_storageStoreFunction;
	std::optional<BuiltinHandle> m_storageLoadFunction;
	std::optional<BuiltinHandle> m_hashFunction;
	AuxiliaryBuiltinHandles m_auxiliaryBuiltinHandles;
};

}
