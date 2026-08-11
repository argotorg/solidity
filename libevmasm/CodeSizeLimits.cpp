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

#include <libevmasm/CodeSizeLimits.h>

#include <liblangutil/ErrorReporter.h>

using namespace std::string_literals;
using namespace solidity::langutil;

namespace solidity::evmasm
{

namespace
{

/// Runtime code size limit (in bytes) introduced by EIP-170 in the Spurious Dragon release.
constexpr size_t RUNTIME_CODE_SIZE_LIMIT = 24576;

/// Initcode size limit (in bytes) introduced by EIP-3860 in the Shanghai release.
constexpr size_t CREATION_CODE_SIZE_LIMIT = 49152;

}

void checkCodeSizeLimits(
	ErrorReporter& _errorReporter,
	EVMVersion _evmVersion,
	SourceLocation const& _location,
	size_t _creationCodeSize,
	size_t _runtimeCodeSize
)
{
	// Warn if EIP-170 limits are exceeded.
	if (_evmVersion >= EVMVersion::spuriousDragon() && _runtimeCodeSize > RUNTIME_CODE_SIZE_LIMIT)
		_errorReporter.warning(
			5574_error,
			_location,
			"Contract code size is "s +
			std::to_string(_runtimeCodeSize) +
			" bytes and exceeds " + std::to_string(RUNTIME_CODE_SIZE_LIMIT) +
			" bytes (a limit introduced in Spurious Dragon). "
			"This contract may not be deployable on Mainnet. "
			"Consider enabling the optimizer (with a low \"runs\" value!), "
			"turning off revert strings, or using libraries."
		);

	// Warn if EIP-3860 limits are exceeded.
	if (_evmVersion >= EVMVersion::shanghai() && _creationCodeSize > CREATION_CODE_SIZE_LIMIT)
		_errorReporter.warning(
			3860_error,
			_location,
			"Contract initcode size is "s +
			std::to_string(_creationCodeSize) +
			" bytes and exceeds " + std::to_string(CREATION_CODE_SIZE_LIMIT) +
			" bytes (a limit introduced in Shanghai). "
			"This contract may not be deployable on Mainnet. "
			"Consider enabling the optimizer (with a low \"runs\" value!), "
			"turning off revert strings, or using libraries."
		);
}

}
