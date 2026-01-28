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

#include <libsolutil/Common.h>
#include <libsolutil/JSON.h>

#include <concepts>
#include <optional>
#include <variant>
#include <vector>

namespace solidity::evmasm::ethdebug::schema
{

struct EthdebugException: virtual util::Exception {};

namespace data
{

struct HexValue
{
	bytes value;
};

struct Unsigned
{
	template<std::unsigned_integral T>
	Unsigned(T const _value)
	{
		solRequire(static_cast<T>(_value) <= std::numeric_limits<std::uint64_t>::max(), EthdebugException, "Too large value.");
		value = static_cast<std::uint64_t>(_value);
	}
	template<std::signed_integral T>
	Unsigned(T const _value)
	{
		solRequire(_value >= 0, EthdebugException, "NonNegativeValue got negative value.");
		solRequire(static_cast<std::make_unsigned_t<T>>(_value) <= std::numeric_limits<std::uint64_t>::max(), EthdebugException, "Too large value.");
		value = static_cast<std::uint64_t>(_value);
	}
	Unsigned(HexValue&& _value): value(std::move(_value)) {}

	std::variant<std::uint64_t, HexValue> value;
};

}

namespace materials
{

struct ID
{
	std::variant<std::string, std::uint64_t> value;
};

struct Reference
{
	enum class Type { Compilation, Source };
	ID id;
	std::optional<Type> type;
};

struct SourceRange
{
	struct Range
	{
		data::Unsigned length;
		data::Unsigned offset;
	};

	Reference source;
	std::optional<Range> range;
};

}

namespace program
{

struct Context
{
	struct Variable
	{
		std::optional<std::string> identifier;
		std::optional<materials::SourceRange> declaration;
		// TODO: type
		// TODO: pointer according to ethdebug/format/spec/pointer
	};

	std::optional<materials::SourceRange> code;
	std::optional<std::vector<Variable>> variables;
	std::optional<std::string> remark;
};

struct Instruction
{
	struct Operation
	{
		std::string mnemonic;
		std::vector<data::Unsigned> arguments;
	};

	data::Unsigned offset;
	std::optional<Operation> operation;
	std::optional<Context> context;
};

}

struct Program
{
	enum class Environment
	{
		CALL, CREATE
	};

	struct Contract
	{
		std::optional<std::string> name;
		materials::SourceRange definition;
	};

	std::optional<materials::Reference> compilation;
	Contract contract;
	Environment environment;
	std::optional<program::Context> context;
	std::vector<program::Instruction> instructions;
};

namespace data
{
void to_json(Json& _json, HexValue const& _hexValue);
void to_json(Json& _json, Unsigned const& _unsigned);
}

namespace materials
{
void to_json(Json& _json, ID const& _id);
void to_json(Json& _json, Reference const& _source);
void to_json(Json& _json, SourceRange::Range const& _range);
void to_json(Json& _json, SourceRange const& _sourceRange);
}

namespace program
{
void to_json(Json& _json, Context::Variable const& _contextVariable);
void to_json(Json& _json, Context const& _context);
void to_json(Json& _json, Instruction::Operation const& _operation);
void to_json(Json& _json, Instruction const& _instruction);
}

void to_json(Json& _json, Program::Contract const& _contract);
void to_json(Json& _json, Program::Environment const& _environment);
void to_json(Json& _json, Program const& _program);

}
