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

#include <liblangutil/SemanticDebugDataSerialization.h>

#include <liblangutil/SemanticDebugDataAnalysis.h>

#include <libsolutil/Numeric.h>

#include <cctype>
#include <charconv>
#include <limits>
#include <memory>
#include <set>
#include <string>
#include <string_view>
#include <type_traits>
#include <utility>

using namespace solidity;
using namespace solidity::langutil;

namespace
{

/// Sidecars nest pointers and expressions recursively; a document deeper than
/// this is rejected rather than parsed with unbounded recursion.
constexpr size_t maximumNestingDepth = 256;

/// Expressions internal to the compiler use this prefix, which cannot clash
/// with the schema's own `$` forms.
constexpr std::string_view internalExpressionPrefix = "$$";
constexpr std::string_view yulLocalKey = "$$yulLocal";

void require(bool _condition, std::string const& _message)
{
	solRequire(_condition, SemanticDebugDataSerializationError, _message);
}

void requireObject(Json const& _json, std::string const& _path)
{
	require(_json.is_object(), _path + " must be an object.");
}

void requireArray(Json const& _json, std::string const& _path)
{
	require(_json.is_array(), _path + " must be an array.");
}

/// Rejects members outside @a _allowed: the format is versioned, so an
/// unknown member is a mistake rather than an extension.
void requireOnlyMembers(Json const& _json, std::set<std::string_view> const& _allowed, std::string const& _path)
{
	requireObject(_json, _path);
	for (auto const& [name, value]: _json.items())
		require(_allowed.count(name), _path + " has an unknown member \"" + name + "\".");
}

Json const& requiredMember(Json const& _json, std::string const& _name, std::string const& _path)
{
	requireObject(_json, _path);
	require(_json.contains(_name), _path + "." + _name + " is required.");
	return _json.at(_name);
}

std::string requiredString(Json const& _json, std::string const& _name, std::string const& _path)
{
	Json const& value = requiredMember(_json, _name, _path);
	require(value.is_string(), _path + "." + _name + " must be a string.");
	return value.get<std::string>();
}

template<class T>
T integerValue(Json const& _value, std::string const& _path)
{
	require(_value.is_number_integer(), _path + " must be an integer.");
	if constexpr (std::is_unsigned_v<T>)
	{
		require(
			_value.is_number_unsigned() || _value.get<Json::number_integer_t>() >= 0,
			_path + " must not be negative."
		);
		require(_value.get<Json::number_unsigned_t>() <= std::numeric_limits<T>::max(), _path + " is too large.");
	}
	else if (_value.is_number_unsigned())
		require(
			_value.get<Json::number_unsigned_t>() <= static_cast<Json::number_unsigned_t>(std::numeric_limits<T>::max()),
			_path + " is too large."
		);
	else
	{
		Json::number_integer_t const rawValue = _value.get<Json::number_integer_t>();
		require(rawValue >= std::numeric_limits<T>::min(), _path + " is too small.");
		require(rawValue <= std::numeric_limits<T>::max(), _path + " is too large.");
	}
	return _value.get<T>();
}

template<class T>
T requiredInteger(Json const& _json, std::string const& _name, std::string const& _path)
{
	return integerValue<T>(requiredMember(_json, _name, _path), _path + "." + _name);
}

template<class T>
std::optional<T> optionalInteger(Json const& _json, std::string const& _name, std::string const& _path)
{
	if (!_json.contains(_name))
		return std::nullopt;
	return integerValue<T>(_json.at(_name), _path + "." + _name);
}

std::optional<std::string> optionalString(Json const& _json, std::string const& _name, std::string const& _path)
{
	if (!_json.contains(_name))
		return std::nullopt;
	Json const& value = _json.at(_name);
	require(value.is_string(), _path + "." + _name + " must be a string.");
	return value.get<std::string>();
}

template<class T>
void setOptional(Json& _json, std::string const& _name, std::optional<T> const& _value)
{
	if (_value)
		_json[_name] = *_value;
}

/// Phase values use the compiler's dash-separated convention for enumeration
/// values, like `ast-id` in the debug info selection.
using Phase = SemanticDebugVariablePhase;
constexpr std::pair<Phase, std::string_view> phaseNames[]{
	{Phase::Materialized, "materialized"},
	{Phase::Computed, "computed"},
	{Phase::OptimizedOut, "optimized-out"}
};

using PointerLocation = SemanticDebugPointer::Location;
constexpr std::pair<PointerLocation, std::string_view> pointerLocationNames[]{
	{PointerLocation::Stack, "stack"},
	{PointerLocation::Storage, "storage"},
	{PointerLocation::Transient, "transient"},
	{PointerLocation::Memory, "memory"},
	{PointerLocation::Calldata, "calldata"},
	{PointerLocation::Returndata, "returndata"},
	{PointerLocation::Code, "code"}
};

template<class Enum, class Names>
std::string enumToString(Enum _value, Names const& _names)
{
	for (auto const& [value, name]: _names)
		if (_value == value)
			return std::string(name);
	solAssert(false, "Unhandled semantic debug data enum value.");
}

template<class Names>
auto enumFromString(std::string const& _name, Names const& _names, std::string const& _path)
	-> std::decay_t<decltype(std::begin(_names)->first)>
{
	for (auto const& [value, name]: _names)
		if (_name == name)
			return value;
	solThrow(SemanticDebugDataSerializationError, _path + " has unknown value \"" + _name + "\".");
}

/// The pointer schema's identifier grammar: `^[a-zA-Z_\-]+[a-zA-Z0-9$_\-]*$`.
bool isIdentifier(std::string_view _text)
{
	auto const isStart = [](char _c) { return std::isalpha(static_cast<unsigned char>(_c)) || _c == '_' || _c == '-'; };
	auto const isRest = [&](char _c) { return isStart(_c) || std::isdigit(static_cast<unsigned char>(_c)) || _c == '$'; };
	if (_text.empty() || !isStart(_text.front()))
		return false;
	for (char const c: _text)
		if (!isRest(c))
			return false;
	return true;
}

/// A literal in its canonical form: `0x` followed by at least one hex digit.
bool isHexLiteral(std::string_view _text)
{
	if (_text.size() < 3 || _text.substr(0, 2) != "0x")
		return false;
	for (char const c: _text.substr(2))
		if (!std::isxdigit(static_cast<unsigned char>(c)))
			return false;
	return true;
}

/// A positive decimal number without leading zeros, as `$sized<N>` requires.
bool isPositiveDecimal(std::string_view _text)
{
	if (_text.empty() || _text.front() == '0')
		return false;
	for (char const c: _text)
		if (!std::isdigit(static_cast<unsigned char>(c)))
			return false;
	return true;
}

/// Word-oriented locations address by slot, byte-oriented ones by offset and
/// length, as the schema's segment and slice addressing schemes require.
bool isWordOriented(PointerLocation _location)
{
	return _location == PointerLocation::Stack || _location == PointerLocation::Storage || _location == PointerLocation::Transient;
}

void requireRegionFields(SemanticDebugPointer const& _region, std::string const& _path)
{
	require(_region.location.has_value() && *_region.location != PointerLocation::Unknown, _path + " must state a location.");
	require(!_region.name || isIdentifier(*_region.name), _path + ".name must be an identifier.");
	if (isWordOriented(*_region.location))
		require(_region.slot.has_value(), _path + " must address its slot.");
	else
		require(_region.offset.has_value() && _region.length.has_value(), _path + " must address its offset and length.");
}

/// Source ranges are serialized in the shape of the schema's
/// materials/source-range. The source ID is the one the accompanying
/// ethdebug.compilation record uses, transported as an opaque number.
Json sourceRangeToJson(SemanticDebugSourceRange const& _range)
{
	require(_range.offset >= 0 && _range.length >= 0, "Cannot serialize an invalid source range.");
	return Json{
		{"source", Json{{"id", _range.sourceID}}},
		{"range", Json{{"length", _range.length}, {"offset", _range.offset}}}
	};
}

SemanticDebugSourceRange sourceRangeFromJson(Json const& _json, std::string const& _path)
{
	requireOnlyMembers(_json, {"source", "range"}, _path);
	SemanticDebugSourceRange result;
	Json const& source = requiredMember(_json, "source", _path);
	requireOnlyMembers(source, {"id"}, _path + ".source");
	result.sourceID = requiredInteger<uint64_t>(source, "id", _path + ".source");
	Json const& range = requiredMember(_json, "range", _path);
	requireOnlyMembers(range, {"offset", "length"}, _path + ".range");
	result.offset = requiredInteger<int>(range, "offset", _path + ".range");
	result.length = requiredInteger<int>(range, "length", _path + ".range");
	require(result.offset >= 0 && result.length >= 0, _path + ".range must not be negative.");
	return result;
}

Json expressionToJson(SemanticDebugPointerExpression const& _expression);
Json pointerBodyToJson(SemanticDebugPointer const& _pointer);
SemanticDebugPointerExpression expressionFromJson(Json const& _json, std::string const& _path, size_t _depth);
SemanticDebugPointer pointerFromJson(Json const& _json, std::string const& _path, size_t _depth);
SemanticDebugPointer templateFromJson(Json const& _json, std::string const& _path, size_t _depth);

/// Pointer expressions are serialized in the ethdebug pointer expression
/// grammar itself: `0x` strings for literals, identifiers for bound variables,
/// `"$wordsize"`, and single-key objects for lookups, reads, arithmetic and
/// resizing. The one internal form, `{"$$yulLocal": ...}`, has no schema
/// counterpart: it names a stack depth that is not known yet.
Json expressionToJson(SemanticDebugPointerExpression const& _expression)
{
	using Kind = SemanticDebugPointerExpression::Kind;

	auto const operands = [&](size_t _arity = 0) {
		require(
			_arity == 0 ? !_expression.operands.empty() : _expression.operands.size() == _arity,
			"Pointer expression has the wrong number of operands."
		);
		Json result = Json::array();
		for (SemanticDebugPointerExpression const& operand: _expression.operands)
			result.emplace_back(expressionToJson(operand));
		return result;
	};
	auto const value = [&]() -> std::string const& {
		require(_expression.value.has_value(), "Pointer expression lacks its value.");
		return *_expression.value;
	};

	switch (_expression.kind)
	{
	case Kind::Literal:
		require(isHexLiteral(value()), "Pointer expression literal \"" + value() + "\" is not a hex literal.");
		return Json(value());
	case Kind::Variable:
		require(isIdentifier(value()), "Pointer expression variable \"" + value() + "\" is not an identifier.");
		return Json(value());
	case Kind::YulLocal:
		return Json{{std::string(yulLocalKey), value()}};
	case Kind::WordSize:
		return Json("$wordsize");
	case Kind::LookupSlot:
		return Json{{".slot", value()}};
	case Kind::LookupOffset:
		return Json{{".offset", value()}};
	case Kind::LookupLength:
		return Json{{".length", value()}};
	case Kind::Read:
		return Json{{"$read", value()}};
	case Kind::Sum:
		return Json{{"$sum", operands()}};
	case Kind::Product:
		return Json{{"$product", operands()}};
	case Kind::Difference:
		return Json{{"$difference", operands(2)}};
	case Kind::Quotient:
		return Json{{"$quotient", operands(2)}};
	case Kind::Remainder:
		return Json{{"$remainder", operands(2)}};
	case Kind::Keccak256:
		return Json{{"$keccak256", operands()}};
	case Kind::Concat:
		return Json{{"$concat", operands()}};
	case Kind::Resize:
		require(_expression.operands.size() == 1, "A resize expression takes exactly one operand.");
		if (!_expression.value)
			return Json{{"$wordsized", expressionToJson(_expression.operands.front())}};
		require(isPositiveDecimal(*_expression.value), "A sized resize expression needs a positive byte width.");
		return Json{{"$sized" + *_expression.value, expressionToJson(_expression.operands.front())}};
	case Kind::Unknown:
		break;
	}
	solThrow(SemanticDebugDataSerializationError, "Cannot serialize an unknown pointer expression.");
}

SemanticDebugPointerExpression expressionFromJson(Json const& _json, std::string const& _path, size_t _depth)
{
	using Kind = SemanticDebugPointerExpression::Kind;
	require(_depth < maximumNestingDepth, _path + " is nested too deeply.");
	SemanticDebugPointerExpression result;

	if (_json.is_number_integer())
	{
		require(_json.is_number_unsigned() || _json.get<Json::number_integer_t>() >= 0, _path + " must not be negative.");
		return SemanticDebugPointerExpression::literal(toCompactHexWithPrefix(u256(_json.get<Json::number_unsigned_t>())));
	}
	if (_json.is_string())
	{
		std::string text = _json.get<std::string>();
		if (text == "$wordsize")
			return SemanticDebugPointerExpression::wordSize();
		if (isHexLiteral(text))
			return SemanticDebugPointerExpression::literal(std::move(text));
		require(isIdentifier(text), _path + " is neither a hex literal nor an identifier.");
		return SemanticDebugPointerExpression::variable(std::move(text));
	}

	requireObject(_json, _path);
	require(_json.size() == 1, _path + " must have exactly one member.");
	std::string const key = _json.begin().key();
	Json const& value = _json.begin().value();
	std::string const valuePath = _path + "." + key;

	auto const regionName = [&](Kind _kind) {
		require(value.is_string() && isIdentifier(value.get<std::string>()), valuePath + " must name a region.");
		result.kind = _kind;
		result.value = value.get<std::string>();
	};
	auto const operands = [&](Kind _kind, size_t _arity = 0) {
		requireArray(value, valuePath);
		require(
			_arity == 0 ? !value.empty() : value.size() == _arity,
			valuePath + " has the wrong number of operands."
		);
		result.kind = _kind;
		for (size_t index = 0; index < value.size(); ++index)
			result.operands.emplace_back(
				expressionFromJson(value.at(index), valuePath + "[" + std::to_string(index) + "]", _depth + 1)
			);
	};

	if (key == ".slot")
		regionName(Kind::LookupSlot);
	else if (key == ".offset")
		regionName(Kind::LookupOffset);
	else if (key == ".length")
		regionName(Kind::LookupLength);
	else if (key == "$read")
		regionName(Kind::Read);
	else if (key == yulLocalKey)
	{
		require(value.is_string() && !value.get<std::string>().empty(), valuePath + " must name a Yul variable.");
		result.kind = Kind::YulLocal;
		result.value = value.get<std::string>();
	}
	else if (key == "$sum")
		operands(Kind::Sum);
	else if (key == "$product")
		operands(Kind::Product);
	else if (key == "$difference")
		operands(Kind::Difference, 2);
	else if (key == "$quotient")
		operands(Kind::Quotient, 2);
	else if (key == "$remainder")
		operands(Kind::Remainder, 2);
	else if (key == "$keccak256")
		operands(Kind::Keccak256);
	else if (key == "$concat")
		operands(Kind::Concat);
	else if (key == "$wordsized")
	{
		result.kind = Kind::Resize;
		result.operands.emplace_back(expressionFromJson(value, valuePath, _depth + 1));
	}
	else if (key.starts_with("$sized"))
	{
		std::string width = key.substr(6);
		require(isPositiveDecimal(width), _path + ": malformed resize key \"" + key + "\".");
		result.kind = Kind::Resize;
		result.value = std::move(width);
		result.operands.emplace_back(expressionFromJson(value, valuePath, _depth + 1));
	}
	else if (key.starts_with(internalExpressionPrefix))
		solThrow(SemanticDebugDataSerializationError, _path + ": unknown internal pointer expression \"" + key + "\".");
	else
		solThrow(SemanticDebugDataSerializationError, _path + ": unknown pointer expression key \"" + key + "\".");
	return result;
}

/// Pointers are serialized as ethdebug pointer documents. The class is
/// structural, exactly as in the schema: a region has a `location`, a group
/// has `group`, a list has `list`, a conditional has `if`, a scope is a
/// `define`/`in` chain, a template reference has `template`, and locally
/// defined templates are a `templates`/`in` pair.
Json pointerBodyToJson(SemanticDebugPointer const& _pointer)
{
	using Class = SemanticDebugPointer::Class;

	switch (_pointer.pointerClass)
	{
	case Class::Region:
	{
		requireRegionFields(_pointer, "Region pointer");
		Json result = Json::object();
		setOptional(result, "name", _pointer.name);
		result["location"] = enumToString(*_pointer.location, pointerLocationNames);
		for (auto const& [name, expression]: {
			std::pair{"slot", &_pointer.slot}, std::pair{"offset", &_pointer.offset}, std::pair{"length", &_pointer.length}
		})
			if (expression->has_value())
				result[name] = expressionToJson(**expression);
		return result;
	}
	case Class::Group:
	{
		require(!_pointer.group.empty(), "A group pointer must have at least one member.");
		Json members = Json::array();
		for (SemanticDebugPointer const& member: _pointer.group)
			members.emplace_back(semanticDebugPointerToJson(member));
		return Json{{"group", std::move(members)}};
	}
	case Class::List:
	{
		require(
			_pointer.indexName.has_value() && isIdentifier(*_pointer.indexName) && _pointer.listElement != nullptr,
			"A list pointer must bind an index name and an element."
		);
		Json list = Json::object();
		if (_pointer.count)
			list["count"] = expressionToJson(*_pointer.count);
		list["each"] = *_pointer.indexName;
		list["is"] = semanticDebugPointerToJson(*_pointer.listElement);
		return Json{{"list", std::move(list)}};
	}
	case Class::Conditional:
	{
		require(
			_pointer.condition.has_value() && _pointer.thenPointer != nullptr,
			"A conditional pointer must have a condition and a consequent."
		);
		Json result{
			{"if", expressionToJson(*_pointer.condition)},
			{"then", semanticDebugPointerToJson(*_pointer.thenPointer)}
		};
		if (_pointer.elsePointer)
			result["else"] = semanticDebugPointerToJson(*_pointer.elsePointer);
		return result;
	}
	case Class::Scope:
	{
		require(
			!_pointer.definitions.empty() && _pointer.scopeTarget != nullptr,
			"A scope pointer must define at least one name for its target."
		);
		// Scope definitions are ordered while JSON object members are not,
		// so each definition becomes its own define/in level.
		Json inner = semanticDebugPointerToJson(*_pointer.scopeTarget);
		for (auto definition = _pointer.definitions.rbegin(); definition != _pointer.definitions.rend(); ++definition)
		{
			require(isIdentifier(definition->first), "A scope definition must bind an identifier.");
			inner = Json{
				{"define", Json{{definition->first, expressionToJson(definition->second)}}},
				{"in", std::move(inner)}
			};
		}
		return inner;
	}
	case Class::TemplateReference:
	{
		require(
			_pointer.templateName.has_value() && isIdentifier(*_pointer.templateName),
			"A template reference must name its template."
		);
		Json result{{"template", *_pointer.templateName}};
		if (!_pointer.yields.empty())
		{
			Json yields = Json::object();
			for (auto const& [producedName, newName]: _pointer.yields)
			{
				require(isIdentifier(producedName) && isIdentifier(newName), "A template reference must yield identifiers.");
				yields[producedName] = newName;
			}
			result["yields"] = std::move(yields);
		}
		return result;
	}
	case Class::Templates:
	{
		require(_pointer.scopeTarget != nullptr, "A templates pointer must have a target.");
		Json templates = Json::object();
		for (auto const& [templateName, definition]: _pointer.templates)
		{
			require(isIdentifier(templateName) && definition != nullptr, "A local pointer template must have a name and a definition.");
			templates[templateName] = semanticDebugPointerTemplateToJson(*definition);
		}
		return Json{{"templates", std::move(templates)}, {"in", semanticDebugPointerToJson(*_pointer.scopeTarget)}};
	}
	case Class::Unknown:
		break;
	}
	solThrow(SemanticDebugDataSerializationError, "Cannot serialize an unknown pointer class.");
}

SemanticDebugPointer pointerFromJson(Json const& _json, std::string const& _path, size_t _depth)
{
	using Class = SemanticDebugPointer::Class;

	require(_depth < maximumNestingDepth, _path + " is nested too deeply.");
	requireObject(_json, _path);

	SemanticDebugPointer result;
	if (_json.contains("location"))
	{
		requireOnlyMembers(_json, {"name", "location", "slot", "offset", "length"}, _path);
		result.pointerClass = Class::Region;
		result.name = optionalString(_json, "name", _path);
		result.location = enumFromString(requiredString(_json, "location", _path), pointerLocationNames, _path + ".location");
		for (auto const& [name, expression]: {
			std::pair{"slot", &result.slot}, std::pair{"offset", &result.offset}, std::pair{"length", &result.length}
		})
			if (_json.contains(name))
				*expression = expressionFromJson(_json.at(name), _path + "." + name, _depth + 1);
		requireRegionFields(result, _path);
	}
	else if (_json.contains("group"))
	{
		requireOnlyMembers(_json, {"group"}, _path);
		result.pointerClass = Class::Group;
		Json const& members = _json.at("group");
		requireArray(members, _path + ".group");
		require(!members.empty(), _path + ".group must have at least one member.");
		for (size_t index = 0; index < members.size(); ++index)
			result.group.emplace_back(
				pointerFromJson(members.at(index), _path + ".group[" + std::to_string(index) + "]", _depth + 1)
			);
	}
	else if (_json.contains("list"))
	{
		requireOnlyMembers(_json, {"list"}, _path);
		result.pointerClass = Class::List;
		Json const& list = _json.at("list");
		requireOnlyMembers(list, {"count", "each", "is"}, _path + ".list");
		if (list.contains("count"))
			result.count = expressionFromJson(list.at("count"), _path + ".list.count", _depth + 1);
		result.indexName = requiredString(list, "each", _path + ".list");
		require(isIdentifier(*result.indexName), _path + ".list.each must be an identifier.");
		result.listElement = std::make_shared<SemanticDebugPointer const>(
			pointerFromJson(requiredMember(list, "is", _path + ".list"), _path + ".list.is", _depth + 1)
		);
	}
	else if (_json.contains("if"))
	{
		requireOnlyMembers(_json, {"if", "then", "else"}, _path);
		result.pointerClass = Class::Conditional;
		result.condition = expressionFromJson(_json.at("if"), _path + ".if", _depth + 1);
		result.thenPointer = std::make_shared<SemanticDebugPointer const>(
			pointerFromJson(requiredMember(_json, "then", _path), _path + ".then", _depth + 1)
		);
		if (_json.contains("else"))
			result.elsePointer = std::make_shared<SemanticDebugPointer const>(
				pointerFromJson(_json.at("else"), _path + ".else", _depth + 1)
			);
	}
	else if (_json.contains("define"))
	{
		// A define/in chain is folded back into one ordered definition list.
		// The members of one define object cannot reference each other, so
		// their order within that object does not matter.
		result.pointerClass = Class::Scope;
		Json const* current = &_json;
		std::string path = _path;
		size_t depth = _depth;
		while (current->contains("define"))
		{
			require(depth < maximumNestingDepth, path + " is nested too deeply.");
			requireOnlyMembers(*current, {"define", "in"}, path);
			Json const& define = current->at("define");
			requireObject(define, path + ".define");
			require(!define.empty(), path + ".define must define at least one name.");
			for (auto const& [name, value]: define.items())
			{
				require(isIdentifier(name), path + ".define." + name + " is not an identifier.");
				result.definitions.emplace_back(name, expressionFromJson(value, path + ".define." + name, depth + 1));
			}
			current = &requiredMember(*current, "in", path);
			path += ".in";
			++depth;
		}
		result.scopeTarget = std::make_shared<SemanticDebugPointer const>(pointerFromJson(*current, path, depth));
	}
	else if (_json.contains("template"))
	{
		requireOnlyMembers(_json, {"template", "yields"}, _path);
		result.pointerClass = Class::TemplateReference;
		result.templateName = requiredString(_json, "template", _path);
		require(isIdentifier(*result.templateName), _path + ".template must be an identifier.");
		if (_json.contains("yields"))
		{
			Json const& yields = _json.at("yields");
			requireObject(yields, _path + ".yields");
			for (auto const& [producedName, newName]: yields.items())
			{
				require(
					isIdentifier(producedName) && newName.is_string() && isIdentifier(newName.get<std::string>()),
					_path + ".yields." + producedName + " must map an identifier to an identifier."
				);
				result.yields.emplace_back(producedName, newName.get<std::string>());
			}
		}
	}
	else if (_json.contains("templates"))
	{
		requireOnlyMembers(_json, {"templates", "in"}, _path);
		result.pointerClass = Class::Templates;
		Json const& templates = _json.at("templates");
		requireObject(templates, _path + ".templates");
		for (auto const& [templateName, definition]: templates.items())
		{
			require(isIdentifier(templateName), _path + ".templates." + templateName + " is not an identifier.");
			result.templates.emplace_back(
				templateName,
				std::make_shared<SemanticDebugPointer const>(
					templateFromJson(definition, _path + ".templates." + templateName, _depth + 1)
				)
			);
		}
		result.scopeTarget = std::make_shared<SemanticDebugPointer const>(
			pointerFromJson(requiredMember(_json, "in", _path), _path + ".in", _depth + 1)
		);
	}
	else
		solThrow(
			SemanticDebugDataSerializationError,
			_path + " is not a pointer: expected one of location, group, list, if, define, template or templates."
		);
	return result;
}

SemanticDebugPointer templateFromJson(Json const& _json, std::string const& _path, size_t _depth)
{
	requireOnlyMembers(_json, {"expect", "for"}, _path);
	Json const& expect = requiredMember(_json, "expect", _path);
	requireArray(expect, _path + ".expect");
	// Templates occur only in the table and in local templates blocks; a
	// template in a pointer position, including this one's body, is rejected.
	SemanticDebugPointer result = pointerFromJson(requiredMember(_json, "for", _path), _path + ".for", _depth + 1);
	for (size_t index = 0; index < expect.size(); ++index)
	{
		std::string const parameterPath = _path + ".expect[" + std::to_string(index) + "]";
		require(expect.at(index).is_string(), parameterPath + " must be a string.");
		result.expectedParameters.emplace_back(expect.at(index).get<std::string>());
		require(isIdentifier(result.expectedParameters.back()), parameterPath + " must be an identifier.");
	}
	return result;
}

/// A materialized variable has a pointer; a computed or optimized-out
/// variable does not.
void requirePhaseConsistency(std::optional<Phase> _phase, bool _hasPointer, std::string const& _path)
{
	if (!_phase)
		return;
	if (*_phase == Phase::Materialized)
		require(_hasPointer, _path + ": a materialized variable must have a pointer.");
	else
		require(!_hasPointer, _path + ": a " + enumToString(*_phase, phaseNames) + " variable must not have a pointer.");
}

Json variableToJson(SemanticDebugVariable const& _variable)
{
	require(!_variable.identifier || !_variable.identifier->empty(), "Variable identifier must not be empty.");
	requirePhaseConsistency(_variable.phase, _variable.pointer.has_value(), "variable");
	Json result = Json::object();
	setOptional(result, "identifier", _variable.identifier);
	setOptional(result, "declarationASTID", _variable.declarationASTID);
	if (_variable.declarationSourceRange)
		result["declarationSourceRange"] = sourceRangeToJson(*_variable.declarationSourceRange);
	setOptional(result, "typeID", _variable.typeID);
	result["phase"] = enumToString(_variable.phase, phaseNames);
	if (_variable.pointer)
		result["pointer"] = semanticDebugPointerToJson(*_variable.pointer);
	return result;
}

SemanticDebugVariable variableFromJson(Json const& _json, std::string const& _path)
{
	requireOnlyMembers(
		_json, {"identifier", "declarationASTID", "declarationSourceRange", "typeID", "phase", "pointer"}, _path
	);
	SemanticDebugVariable result;
	result.identifier = optionalString(_json, "identifier", _path);
	require(!result.identifier || !result.identifier->empty(), _path + ".identifier must not be empty.");
	result.declarationASTID = optionalInteger<int64_t>(_json, "declarationASTID", _path);
	if (_json.contains("declarationSourceRange"))
		result.declarationSourceRange = sourceRangeFromJson(_json.at("declarationSourceRange"), _path + ".declarationSourceRange");
	result.typeID = optionalString(_json, "typeID", _path);
	result.phase = enumFromString(requiredString(_json, "phase", _path), phaseNames, _path + ".phase");
	if (_json.contains("pointer"))
		result.pointer = pointerFromJson(_json.at("pointer"), _path + ".pointer", 0);
	requirePhaseConsistency(result.phase, result.pointer.has_value(), _path);
	return result;
}

Json variableUpdateToJson(SemanticDebugVariableUpdate const& _update)
{
	require(_update.phase.has_value() || _update.pointer.has_value(), "A variable update must change the phase or the pointer.");
	requirePhaseConsistency(_update.phase, _update.pointer.has_value(), "variable update");
	Json result{{"variableASTID", _update.variableASTID}};
	if (_update.phase)
		result["phase"] = enumToString(*_update.phase, phaseNames);
	if (_update.pointer)
		result["pointer"] = semanticDebugPointerToJson(*_update.pointer);
	return result;
}

SemanticDebugVariableUpdate variableUpdateFromJson(Json const& _json, std::string const& _path)
{
	requireOnlyMembers(_json, {"variableASTID", "phase", "pointer"}, _path);
	SemanticDebugVariableUpdate result;
	result.variableASTID = requiredInteger<int64_t>(_json, "variableASTID", _path);
	if (_json.contains("phase"))
		result.phase = enumFromString(requiredString(_json, "phase", _path), phaseNames, _path + ".phase");
	if (_json.contains("pointer"))
		result.pointer = pointerFromJson(_json.at("pointer"), _path + ".pointer", 0);
	require(result.phase.has_value() || result.pointer.has_value(), _path + " must change the phase or the pointer.");
	requirePhaseConsistency(result.phase, result.pointer.has_value(), _path);
	return result;
}

Json scopeToJson(SemanticDebugScope const& _scope)
{
	Json result = Json::object();
	result["variableDefinitions"] = Json::array();
	for (auto const& variable: _scope.variableDefinitions)
		result["variableDefinitions"].emplace_back(variableToJson(variable));
	// Omitted while empty, which is all code generation produces: only
	// optimizer passes emit updates.
	if (!_scope.variableUpdates.empty())
	{
		result["variableUpdates"] = Json::array();
		for (auto const& update: _scope.variableUpdates)
			result["variableUpdates"].emplace_back(variableUpdateToJson(update));
	}
	return result;
}

SemanticDebugScope scopeFromJson(Json const& _json, std::string const& _path)
{
	requireOnlyMembers(_json, {"variableDefinitions", "variableUpdates"}, _path);
	SemanticDebugScope result;
	Json const& variables = requiredMember(_json, "variableDefinitions", _path);
	requireArray(variables, _path + ".variableDefinitions");
	for (size_t index = 0; index < variables.size(); ++index)
		result.variableDefinitions.emplace_back(
			variableFromJson(variables.at(index), _path + ".variableDefinitions[" + std::to_string(index) + "]")
		);
	if (_json.contains("variableUpdates"))
	{
		Json const& updates = _json.at("variableUpdates");
		requireArray(updates, _path + ".variableUpdates");
		for (size_t index = 0; index < updates.size(); ++index)
			result.variableUpdates.emplace_back(
				variableUpdateFromJson(updates.at(index), _path + ".variableUpdates[" + std::to_string(index) + "]")
			);
	}
	return result;
}

/// The keys of the two-level scope map are the canonical decimal forms of the
/// AST ID and the instance: an optional sign for the AST ID, digits without
/// leading zeros, within the 64-bit range.
int64_t decimalKey(std::string const& _text, std::string const& _path)
{
	std::string_view digits = _text;
	bool const negative = !digits.empty() && digits.front() == '-';
	if (negative)
		digits.remove_prefix(1);
	bool canonical = !digits.empty() && (digits == "0" ? !negative : digits.front() != '0');
	for (char const digit: digits)
		if (!std::isdigit(static_cast<unsigned char>(digit)))
			canonical = false;
	require(canonical, _path + " key \"" + _text + "\" is not a decimal integer.");

	int64_t value = 0;
	auto const [end, error] = std::from_chars(_text.data(), _text.data() + _text.size(), value);
	require(error == std::errc{} && end == _text.data() + _text.size(), _path + " key \"" + _text + "\" is out of range.");
	return value;
}

int64_t astIDKey(std::string const& _text, std::string const& _path)
{
	return decimalKey(_text, _path);
}

int64_t instanceKey(std::string const& _text, std::string const& _path)
{
	int64_t const instance = decimalKey(_text, _path);
	require(instance >= 0, _path + " key \"" + _text + "\" must not be negative.");
	return instance;
}

/// A template reference must resolve against a local templates block in the
/// same pointer document or against the sidecar's pointer template table.
void requireResolvableTemplateReferences(
	SemanticDebugPointer const& _pointer,
	std::set<std::string> const& _localTemplates,
	SemanticDebugDataTable const& _table,
	std::string const& _path
)
{
	using Class = SemanticDebugPointer::Class;
	auto const recurse = [&](std::shared_ptr<SemanticDebugPointer const> const& _sub, std::string const& _subPath) {
		if (_sub)
			requireResolvableTemplateReferences(*_sub, _localTemplates, _table, _subPath);
	};

	switch (_pointer.pointerClass)
	{
	case Class::TemplateReference:
		require(
			_pointer.templateName.has_value() &&
			(_localTemplates.count(*_pointer.templateName) || _table.findPointerTemplate(*_pointer.templateName)),
			_path + " references unknown pointer template \"" + _pointer.templateName.value_or("") + "\"."
		);
		return;
	case Class::Templates:
	{
		std::set<std::string> localTemplates = _localTemplates;
		for (auto const& [templateName, definition]: _pointer.templates)
		{
			recurse(definition, _path + ".templates." + templateName);
			localTemplates.insert(templateName);
		}
		if (_pointer.scopeTarget)
			requireResolvableTemplateReferences(*_pointer.scopeTarget, localTemplates, _table, _path + ".in");
		return;
	}
	case Class::Group:
		for (size_t index = 0; index < _pointer.group.size(); ++index)
			requireResolvableTemplateReferences(
				_pointer.group[index], _localTemplates, _table, _path + ".group[" + std::to_string(index) + "]"
			);
		return;
	case Class::List:
		recurse(_pointer.listElement, _path + ".list.is");
		return;
	case Class::Conditional:
		recurse(_pointer.thenPointer, _path + ".then");
		recurse(_pointer.elsePointer, _path + ".else");
		return;
	case Class::Scope:
		recurse(_pointer.scopeTarget, _path + ".in");
		return;
	case Class::Region:
	case Class::Unknown:
		return;
	}
}

void requireResolvableTemplateReferences(SemanticDebugDataTable const& _table)
{
	for (auto const& [templateName, definition]: _table.pointerTemplates())
		requireResolvableTemplateReferences(definition, {}, _table, "sidecar.resources.pointers." + templateName);
	for (auto const& [key, scope]: _table.scopes())
	{
		if (!scope)
			continue;
		std::string const path = "sidecar.scopes." + std::to_string(key.first) + "." + std::to_string(key.second);
		for (size_t index = 0; index < scope->variableDefinitions.size(); ++index)
			if (auto const& pointer = scope->variableDefinitions[index].pointer)
				requireResolvableTemplateReferences(
					*pointer, {}, _table, path + ".variableDefinitions[" + std::to_string(index) + "].pointer"
				);
		for (size_t index = 0; index < scope->variableUpdates.size(); ++index)
			if (auto const& pointer = scope->variableUpdates[index].pointer)
				requireResolvableTemplateReferences(
					*pointer, {}, _table, path + ".variableUpdates[" + std::to_string(index) + "].pointer"
				);
	}
}

} // namespace

Json langutil::semanticDebugPointerToJson(SemanticDebugPointer const& _pointer)
{
	if (_pointer.expectedParameters.empty())
		return pointerBodyToJson(_pointer);
	return semanticDebugPointerTemplateToJson(_pointer);
}

Json langutil::semanticDebugPointerTemplateToJson(SemanticDebugPointer const& _template)
{
	Json expect = Json::array();
	for (std::string const& parameter: _template.expectedParameters)
	{
		require(isIdentifier(parameter), "A template parameter must be an identifier.");
		expect.emplace_back(parameter);
	}
	return Json{{"expect", std::move(expect)}, {"for", pointerBodyToJson(_template)}};
}

Json langutil::semanticDebugDataToJson(SemanticDebugDataTable const& _table)
{
	Json result{
		{"format", std::string(SemanticDebugDataFormat)},
		{"version", SemanticDebugDataFormatVersion}
	};
	setOptional(result, "contractName", _table.contractName());

	// The resource tables mirror the public ethdebug.resources object: type
	// documents are written verbatim, they already are the public type
	// schema, and pointer templates in the schema's template form.
	if (!_table.types().empty() || !_table.pointerTemplates().empty())
	{
		Json types = Json::object();
		for (auto const& [id, document]: _table.types())
			types[id] = document;
		Json pointers = Json::object();
		for (auto const& [name, definition]: _table.pointerTemplates())
			pointers[name] = semanticDebugPointerTemplateToJson(definition);
		result["resources"] = Json{{"types", std::move(types)}, {"pointers", std::move(pointers)}};
	}

	// Scope records form a two-level map from the decimal AST ID to the
	// decimal instance, with instance 0 written explicitly. The JSON library
	// orders object members by key, which keeps the output deterministic.
	Json scopes = Json::object();
	for (auto const& [key, scope]: _table.scopes())
	{
		require(scope != nullptr, "Semantic debug data table contains a null scope record.");
		scopes[std::to_string(key.first)][std::to_string(key.second)] = scopeToJson(*scope);
	}
	result["scopes"] = std::move(scopes);
	return result;
}

SemanticDebugDataTable langutil::semanticDebugDataFromJson(Json const& _json)
{
	std::string const root = "sidecar";
	requireOnlyMembers(_json, {"format", "version", "contractName", "resources", "scopes"}, root);
	std::string const format = requiredString(_json, "format", root);
	require(format == SemanticDebugDataFormat, "Unsupported semantic debug data format \"" + format + "\".");
	unsigned const version = requiredInteger<unsigned>(_json, "version", root);
	require(version == SemanticDebugDataFormatVersion, "Unsupported semantic debug data format version " + std::to_string(version) + ".");

	SemanticDebugDataTable result;
	if (std::optional<std::string> contractName = optionalString(_json, "contractName", root))
		result.setContractName(std::move(*contractName));

	if (_json.contains("resources"))
	{
		Json const& resources = _json.at("resources");
		requireOnlyMembers(resources, {"types", "pointers"}, root + ".resources");
		if (resources.contains("types"))
		{
			Json const& types = resources.at("types");
			requireObject(types, root + ".resources.types");
			for (auto const& [typeID, document]: types.items())
			{
				requireObject(document, root + ".resources.types." + typeID);
				result.setType(typeID, document);
			}
		}
		if (resources.contains("pointers"))
		{
			Json const& pointers = resources.at("pointers");
			requireObject(pointers, root + ".resources.pointers");
			for (auto const& [name, definition]: pointers.items())
			{
				std::string const path = root + ".resources.pointers." + name;
				require(isIdentifier(name), path + " is not an identifier.");
				SemanticDebugPointer pointerTemplate = templateFromJson(definition, path, 0);
				// Pointer templates are public resources, published verbatim:
				// an expression internal to the compiler has no place in them.
				require(
					!semanticDebugPointerHasInternalExpression(pointerTemplate),
					path + " must not contain an internal expression."
				);
				result.setPointerTemplate(name, std::move(pointerTemplate));
			}
		}
	}

	Json const& scopes = requiredMember(_json, "scopes", root);
	requireObject(scopes, root + ".scopes");
	for (auto const& [astIDText, instances]: scopes.items())
	{
		std::string const astIDPath = root + ".scopes." + astIDText;
		int64_t const astID = astIDKey(astIDText, root + ".scopes");
		requireObject(instances, astIDPath);
		for (auto const& [instanceText, scope]: instances.items())
			result.set(
				SemanticDebugDataTable::Key{astID, instanceKey(instanceText, astIDPath)},
				std::make_shared<SemanticDebugScope const>(scopeFromJson(scope, astIDPath + "." + instanceText))
			);
	}

	requireResolvableTemplateReferences(result);
	return result;
}
