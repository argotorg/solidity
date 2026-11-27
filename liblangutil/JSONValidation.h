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

#include <set>
#include <string>
#include <string_view>

/// Temporary helpers until we have declarative JSON validation (issue #17259).
namespace solidity::langutil::jsonvalidation
{

/// Malformed JSON input. Entry points must report the exception comment as an input error.
DEV_SIMPLE_EXCEPTION(JSONValidationError);

/// Validates that @a _json is an object.
/// @throws JSONValidationError if it is not an object.
void requireObject(Json const& _json, std::string_view _path);

/// Validates that @a _json is an array.
/// @throws JSONValidationError if it is not an array.
void requireArray(Json const& _json, std::string_view _path);

/// Validates that every member of @a _json is allowed. Listed members need not be present.
/// @throws JSONValidationError if @a _json is not an object or contains an unknown member.
void requireOnlyMembers(Json const& _json, std::set<std::string_view> const& _allowedMembers, std::string_view _path);

/// Validates that @a _json has a member named @a _name. A null value still counts as present.
/// @throws JSONValidationError if @a _json is not an object or the member is absent.
void requireMember(Json const& _json, std::string_view _name, std::string_view _path);

/// Validates the JSON type and, for numeric types, the range of @a _json.
/// @throws JSONValidationError if @a _json cannot be read as @a T.
template<typename T>
void requireValueOfType(Json const& _json, std::string_view _path)
{
	solRequire(
		util::isOfType<T>(_json),
		JSONValidationError,
		std::string(_path) + ": expected " + std::string(util::jsonTypeName<T>()) + "."
	);
}

/// Validates that the required member @a _name can be read as @a T.
/// @throws JSONValidationError if @a _json is not an object or the member is absent or invalid.
template<typename T>
void requireMemberOfType(Json const& _json, std::string_view _name, std::string_view _path)
{
	requireMember(_json, _name, _path);
	requireValueOfType<T>(_json.at(_name), std::string(_path) + "." + std::string(_name));
}

/// Validates the type of @a _name if present. A present null is not treated as absent.
/// @throws JSONValidationError if @a _json is not an object or the member cannot be read as @a T.
template<typename T>
void requireOptionalMemberOfType(Json const& _json, std::string_view _name, std::string_view _path)
{
	requireObject(_json, _path);
	auto const member = _json.find(_name);
	if (member != _json.end())
		requireValueOfType<T>(*member, std::string(_path) + "." + std::string(_name));
}

}
