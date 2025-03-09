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
 * Component that verifies overloads, abstract contracts, function clashes and others
 * checks at contract or function level.
 */

#include <libsolidity/analysis/PostTypeContractLevelChecker.h>

#include <fmt/format.h>
#include <libsolidity/ast/AST.h>
#include <libsolidity/ast/ASTUtils.h>
#include <libsolidity/ast/TypeProvider.h>
#include <libsolutil/FunctionSelector.h>
#include <liblangutil/ErrorReporter.h>

#include <limits>

using namespace solidity;
using namespace solidity::langutil;
using namespace solidity::frontend;
using namespace solidity::util;

bool PostTypeContractLevelChecker::check(SourceUnit const& _sourceUnit)
{
	bool noErrors = true;
	for (auto* contract: ASTNode::filteredNodes<ContractDefinition>(_sourceUnit.nodes()))
		if (!check(*contract))
			noErrors = false;
	return noErrors;
}

bool PostTypeContractLevelChecker::check(ContractDefinition const& _contract)
{
	solAssert(
		_contract.annotation().creationCallGraph.set() &&
		_contract.annotation().deployedCallGraph.set(),
		""
	);

	std::map<uint32_t, std::map<std::string, SourceLocation>> errorHashes;
	for (ErrorDefinition const* error: _contract.interfaceErrors())
	{
		std::string signature = error->functionType(true)->externalSignature();
		uint32_t hash = selectorFromSignatureU32(signature);
		// Fail if there is a different signature for the same hash.
		if (!errorHashes[hash].empty() && !errorHashes[hash].count(signature))
		{
			SourceLocation& otherLocation = errorHashes[hash].begin()->second;
			m_errorReporter.typeError(
				4883_error,
				error->nameLocation(),
				SecondarySourceLocation{}.append("This error has a different signature but the same hash: ", otherLocation),
				"Error signature hash collision for " + error->functionType(true)->externalSignature()
			);
		}
		else
			errorHashes[hash][signature] = error->location();
	}

	if (_contract.storageLayoutSpecifier())
		checkStorageLayoutSpecifier(_contract);

	return !Error::containsErrors(m_errorReporter.errors());
}

void PostTypeContractLevelChecker::checkStorageLayoutSpecifier(ContractDefinition const& _contract)
{
	StorageLayoutSpecifier const* storageLayoutSpecifier = _contract.storageLayoutSpecifier();
	solAssert(storageLayoutSpecifier);
	Expression const& baseSlotExpression = storageLayoutSpecifier->baseSlotExpression();

	if (!*baseSlotExpression.annotation().isPure)
	{
		// TODO: introduce and handle erc7201 as a builtin function
		m_errorReporter.typeError(
			1139_error,
			baseSlotExpression.location(),
			"The base slot of the storage layout must be a compile-time constant expression."
		);
		return;
	}

	auto const* baseSlotExpressionType = type(baseSlotExpression);
	auto const* rationalType = dynamic_cast<RationalNumberType const*>(baseSlotExpressionType);
	if (!rationalType)
	{
		m_errorReporter.typeError(
			6396_error,
			baseSlotExpression.location(),
			"The base slot of the storage layout must evaluate to a rational number."
		);
		return;
	}

	if (rationalType->isFractional())
	{
		m_errorReporter.typeError(
			1763_error,
			baseSlotExpression.location(),
			"The base slot of the storage layout must evaluate to an integer."
		);
		return;
	}
	solAssert(rationalType->value().denominator() == 1);

	bigint baseSlot = rationalType->value().numerator();
	if (!(0 <= baseSlot && baseSlot <= std::numeric_limits<u256>::max()))
	{
		m_errorReporter.typeError(
			6753_error,
			baseSlotExpression.location(),
			fmt::format(
				"The base slot of the storage layout evaluates to {}, which is outside the range of type uint256.",
				formatNumberReadable(baseSlot)
			)
		);
		return;
	}

	solAssert(baseSlotExpressionType->isImplicitlyConvertibleTo(*TypeProvider::uint256()));
	storageLayoutSpecifier->annotation().baseSlot = u256(baseSlot);

	bigint size = contractStorageSizeUpperBound(_contract, VariableDeclaration::Location::Unspecified);
	solAssert(size < bigint(1) << 256);
	if (baseSlot + size >= bigint(1) << 256)
		m_errorReporter.typeError(
			5015_error,
			baseSlotExpression.location(),
			"Contract extends past the end of storage when this base slot value is specified."
		);
}
