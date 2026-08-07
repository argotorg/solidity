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

#pragma once

#include <test/libsolidity/util/BytesUtils.h>
#include <test/libsolidity/util/StandardJSONOutput.h>
#include <test/libsolidity/util/SoltestTypes.h>
#include <test/libsolidity/util/SoltestErrors.h>

#include <libsolutil/CommonData.h>
#include <libsolutil/JSON.h>

#include <boost/algorithm/string.hpp>

namespace solidity::frontend::test
{

using ABITypes = std::vector<ABIType>;

inline std::string formatInputType(output::ABIParameter const& _input)
{
	if (_input.type == "tuple")
	{
		soltestAssert(_input.components, "key \"components\" is not allowed to be empty for tuples");
		auto types = _input.components.value() | ranges::views::transform([&](auto const& input) {
			return formatInputType(input);
		}) | ranges::to<strings>;
		return "(" + boost::algorithm::join(types, ",") + ")";
	}
	return _input.type;
}

inline strings formatInputTypes(output::ABIFunction const& _function, bool _indexed)
{
	return _function.inputs | ranges::views::filter([&](auto const& input) {
		return input.indexed == _indexed;
	}) | ranges::views::transform([&](auto const& input) {
		return formatInputType(input);
	}) | ranges::to<strings>();
}

inline strings formatInputTypes(output::ABIEvent const& _event, bool _indexed)
{
	return _event.inputs | ranges::views::filter([&](auto const& input) {
		return input.indexed == _indexed;
	}) | ranges::views::transform([&](auto const& input) {
		return formatInputType(input);
	}) | ranges::to<strings>();
}


inline std::string formatSignature(output::ABIFunction const& _function)
{
	auto signatureTypes = _function.inputs | ranges::views::transform([&](auto const& input) {
		return formatInputType(input);
	}) | ranges::to<strings>;
	return _function.name + "(" + boost::algorithm::join(signatureTypes, ",") + ")";
}

inline std::string formatSignature(output::ABIEvent const& _event)
{
	auto signatureTypes = _event.inputs | ranges::views::transform([&](auto const& input) {
		return formatInputType(input);
	}) | ranges::to<strings>;
	return _event.name + "(" + boost::algorithm::join(signatureTypes, ",") + ")";
}

inline std::string formatEventParameter(output::ABIEvent const* _event, bool _indexed, size_t _index, bytes const& _data)
{
	auto isPrintableASCII = [](bytes const& s)
	{
		bool zeroes = true;
		for (auto c: s)
		{
			if (static_cast<unsigned>(c) != 0x00)
			{
				zeroes = false;
				if (static_cast<unsigned>(c) <= 0x1f || static_cast<unsigned>(c) >= 0x7f)
					return false;
			} else
				break;
		}
		return !zeroes;
	};

	ABIType abiType(ABIType::Type::Hex);
	if (isPrintableASCII(_data))
		abiType = ABIType(ABIType::Type::String);
	if (_event)
	{
		auto indexedTypes = formatInputTypes(*_event, true);
		auto nonIndexedTypes = formatInputTypes(*_event, false);
		auto const& types = _indexed ? indexedTypes : nonIndexedTypes;
		if (_index < types.size())
		{
			if (types.at(_index) == "bool")
				abiType = ABIType(ABIType::Type::Boolean);
		}
	}
	return BytesUtils::formatBytes(_data, abiType);
}



/**
 * Utility class that aids conversions from contract ABI types stored in a
 * Json value to the internal ABIType representation of isoltest.
 */
class ContractABIUtils
{
public:
	/// Parses and translates Solidity's ABI types as Json string into
	/// a list of internal type representations of isoltest.
	/// Creates parameters from Contract ABI and is used to generate values for
	/// auto-correction during interactive update routine.
	static std::optional<ParameterList> parametersFromABI(
		ErrorReporter& _errorReporter,
		output::ABI const& _contractABI,
		std::string const& _functionSignature
	);

	/// Overwrites _targetParameters if ABI types or sizes given
	/// by _sourceParameters do not match.
	static void overwriteParameters(
		ErrorReporter& _errorReporter,
		ParameterList& _targetParameters,
		ParameterList const& _sourceParameters
	);

	/// If parameter count does not match, take types defined _sourceParameters
	/// and create a warning if so.
	static ParameterList preferredParameters(
		ErrorReporter& _errorReporter,
		ParameterList const& _targetParameters,
		ParameterList const& _sourceParameters,
		bytes const& _bytes
	);

	/// Returns a list of parameters corresponding to the encoding of
	/// returned values in case of a failure. Creates an additional parameter
	/// for the error message if _bytes is larger than 68 bytes
	/// (function_selector + tail_ptr + message_length).
	static ParameterList failureParameters(bytes const& _bytes);

	/// Returns _count parameters with their type set to ABIType::UnsignedDec
	/// and their size set to 32 bytes.
	static ParameterList defaultParameters(size_t count = 0);

	/// Calculates the encoding size of given _parameters based
	/// on the size of their types.
	static size_t encodingSize(ParameterList const& _parameters);

private:
	/// Translates a single type and returns a list of
	/// internal type representations of isoltest.
	/// Types defined by the ABI will translate to ABITypes
	/// as follows:
	/// `bool` -> [`Boolean`]
	/// `uint` -> [`Unsigned`]
	/// `string` -> [`Unsigned`, `Unsigned`, `String`]
	/// `bytes` -> [`Unsigned`, `Unsigned`, `HexString`]
	/// ...
	static bool appendTypesFromName(
		output::ABIParameter const& _functionOutput,
		ABITypes& _inplaceTypes,
		ABITypes& _dynamicTypes,
		bool _isCompoundType = false
	);
};

}
