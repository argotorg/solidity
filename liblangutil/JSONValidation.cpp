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

#include <liblangutil/JSONValidation.h>

namespace solidity::langutil::jsonvalidation
{

void requireObject(Json const& _json, std::string_view _path)
{
	solRequire(_json.is_object(), JSONValidationError, std::string(_path) + ": expected object.");
}

void requireArray(Json const& _json, std::string_view _path)
{
	solRequire(_json.is_array(), JSONValidationError, std::string(_path) + ": expected array.");
}

void requireOnlyMembers(Json const& _json, std::set<std::string_view> const& _allowedMembers, std::string_view _path)
{
	requireObject(_json, _path);
	for (auto const& [name, value]: _json.items())
		solRequire(
			_allowedMembers.contains(name),
			JSONValidationError,
			std::string(_path) + " has an unknown member \"" + name + "\"."
		);
}

void requireMember(Json const& _json, std::string_view _name, std::string_view _path)
{
	requireObject(_json, _path);
	solRequire(
		_json.contains(_name),
		JSONValidationError,
		std::string(_path) + "." + std::string(_name) + " is required."
	);
}

}
