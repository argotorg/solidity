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

#include <libsolutil/Exceptions.h>
#include <libsolutil/JSON.h>

#include <optional>
#include <set>
#include <string>
#include <string_view>
#include <type_traits>

namespace solidity::langutil::ethdebug
{

/// Malformed ETHDebug JSON. Input entry points must report the exception comment as an input error.
DEV_SIMPLE_EXCEPTION(JsonValidationError);

/// Throws JsonValidationError if @a _json is not an object.
void requireObject(Json const& _json, std::string_view _path);
/// Throws JsonValidationError if @a _json is not an array.
void requireArray(Json const& _json, std::string_view _path);
/// Requires an object whose members are all in @a _allowedMembers.
void requireOnlyMembers(Json const& _json, std::set<std::string_view> const& _allowedMembers, std::string_view _path);
/// Requires an object with @a _name and returns the member.
Json const& requireMember(Json const& _json, std::string_view _name, std::string_view _path);
/// Requires an object and returns the member @a _name, or nullptr if absent.
Json const* checkAndFindMember(Json const& _json, std::string_view _name, std::string_view _path);

namespace detail
{

template<typename T>
constexpr std::string_view jsonTypeName()
{
	if constexpr (std::is_same_v<T, Json::string_t>)
		return "string";
	else if constexpr (std::is_same_v<T, Json::boolean_t>)
		return "boolean";
	else if constexpr (std::is_floating_point_v<T>)
		return "number";
	else if constexpr (std::is_unsigned_v<T>)
		return "unsigned integer";
	else
		return "integer";
}

}

/// Requires a value representable as @a T and returns the converted value.
template<typename T>
T requireValueOfType(Json const& _json, std::string_view _path)
{
	solRequire(
		util::isOfType<T>(_json),
		JsonValidationError,
		std::string(_path) + ": expected " + std::string(detail::jsonTypeName<T>()) + "."
	);
	return util::get<T>(_json);
}

/// Requires an object with a member @a _name representable as @a T and returns the converted value.
template<typename T>
T requireMemberOfType(Json const& _json, std::string_view _name, std::string_view _path)
{
	return requireValueOfType<T>(requireMember(_json, _name, _path), std::string(_path) + "." + std::string(_name));
}

/// Requires an object and checks and converts @a _name to @a T if present.
/// A present null is checked like any other value.
template<typename T>
std::optional<T> checkAndReadOptionalMember(Json const& _json, std::string_view _name, std::string_view _path)
{
	Json const* member = checkAndFindMember(_json, _name, _path);
	if (member == nullptr)
		return std::nullopt;
	return requireValueOfType<T>(*member, std::string(_path) + "." + std::string(_name));
}

}
