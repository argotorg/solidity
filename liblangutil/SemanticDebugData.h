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
 * The compiler structures of the semantic debug info specified in
 * docs/internals/ethdebug_internal_debug_info.rst: scope records with their
 * variables, phases and ethdebug pointers.
 */

#pragma once

#include <liblangutil/Exceptions.h>
#include <liblangutil/SourceLocation.h>

#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include <vector>

namespace solidity::langutil
{

// The SemanticDebugData prefix names the compiler structures of the semantic
// debug info specified in docs/internals/ethdebug_internal_debug_info.rst:
// the scope records attached to Yul nodes, their variables and pointers, and
// the side table that carries them across a textual Yul boundary.

/// Whether a variable's value can be recovered at a program point. The region
/// a materialized value lives in is not duplicated here: the variable's pointer
/// already records it.
enum class SemanticDebugVariablePhase
{
	/// The value has a concrete representation described by the variable's pointer.
	Materialized,
	/// The value has no region because the program recomputes it where it is
	/// used. No recovery recipe is carried; the phase only records that
	/// recomputation would be possible in principle, unlike OptimizedOut.
	Computed,
	/// No recoverable representation is available at this program point.
	OptimizedOut
};

/// Source range in the shape of the ethdebug source range schema. The source
/// is identified by the same ID the accompanying ethdebug.compilation record
/// uses; a path is never used as an ID, and the Yul stage transports the ID
/// unchanged without interpreting it.
struct SemanticDebugSourceRange
{
	uint64_t sourceID = 0;
	int offset = 0;
	int length = 0;

	/// The range of @a _location in the source with ID @a _sourceID, or
	/// nothing when the location is empty or the source has no ID.
	static std::optional<SemanticDebugSourceRange> fromLocation(
		SourceLocation const& _location,
		std::optional<uint64_t> _sourceID
	)
	{
		if (!_sourceID || _location.start < 0 || _location.end < _location.start)
			return std::nullopt;
		return SemanticDebugSourceRange{*_sourceID, _location.start, _location.end - _location.start};
	}

	bool operator==(SemanticDebugSourceRange const&) const = default;
};

/// Node in an ethdebug pointer expression tree. Expressions evaluate to
/// unsigned values and may reference named regions and variables bound by
/// scope definitions, list indices or template parameters.
struct SemanticDebugPointerExpression
{
	enum class Kind
	{
		Unknown,
		/// Literal unsigned value. @a value holds the canonical `0x`-prefixed
		/// hex form.
		Literal,
		/// The EVM word size in bytes (`$wordsize`).
		WordSize,
		/// Reference to a variable bound by a scope definition, a list index
		/// name or a template parameter, emitted as written. A variable that
		/// nothing binds is a dependency on the surrounding Yul code, like a
		/// Yul local, and is treated as one by the survival check.
		Variable,
		/// A generated Yul local standing in for a stack depth that is not
		/// known until the Yul-to-EVM transform has run.
		///
		/// Nothing binds the name, so a consumer cannot resolve it, and emitting
		/// it would put a Yul identifier where the public format expects a
		/// slot. It is internal only, serialized as `{"$$yulLocal": ...}` with
		/// the compiler's `$$` prefix that cannot clash with the schema's own
		/// `$` forms, and must be resolved or removed before public emission,
		/// which publishes no pointer still carrying it.
		YulLocal,
		/// `{".slot": <region>}` — the slot defined for the referenced region.
		LookupSlot,
		/// `{".offset": <region>}` — the offset defined for the referenced region.
		LookupOffset,
		/// `{".length": <region>}` — the length defined for the referenced region.
		LookupLength,
		/// `{"$read": <region>}` — the raw machine-state bytes in the referenced region.
		Read,
		/// `{"$sum": [...]}` over any number of operands.
		Sum,
		/// `{"$product": [...]}` over any number of operands.
		Product,
		/// `{"$difference": [a, b]}` — clamped at zero.
		Difference,
		/// `{"$quotient": [a, b]}` — integer division.
		Quotient,
		/// `{"$remainder": [a, b]}` — modular remainder.
		Remainder,
		/// `{"$keccak256": [...]}` — hash of the tightly packed operand bytes.
		Keccak256,
		/// `{"$concat": [...]}` — byte concatenation of the operands.
		Concat,
		/// `{"$sized<N>": x}` when @a value holds the decimal byte width N,
		/// `{"$wordsized": x}` when @a value is unset.
		Resize
	};

	Kind kind = Kind::Unknown;
	/// Payload interpreted according to @a kind: literal value, variable identifier,
	/// referenced region name (or `$this`) or resize width.
	std::optional<std::string> value;
	/// Sub-expressions for arithmetic, hashing, concatenation and resize kinds.
	std::vector<SemanticDebugPointerExpression> operands;

	static SemanticDebugPointerExpression literal(std::string _value)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Literal;
		result.value = std::move(_value);
		return result;
	}

	static SemanticDebugPointerExpression wordSize()
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::WordSize;
		return result;
	}

	static SemanticDebugPointerExpression variable(std::string _identifier)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Variable;
		result.value = std::move(_identifier);
		return result;
	}

	static SemanticDebugPointerExpression yulLocal(std::string _yulName)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::YulLocal;
		result.value = std::move(_yulName);
		return result;
	}

	static SemanticDebugPointerExpression lookupSlot(std::string _region)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::LookupSlot;
		result.value = std::move(_region);
		return result;
	}

	static SemanticDebugPointerExpression lookupOffset(std::string _region)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::LookupOffset;
		result.value = std::move(_region);
		return result;
	}

	static SemanticDebugPointerExpression lookupLength(std::string _region)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::LookupLength;
		result.value = std::move(_region);
		return result;
	}

	static SemanticDebugPointerExpression read(std::string _region)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Read;
		result.value = std::move(_region);
		return result;
	}

	static SemanticDebugPointerExpression sum(std::vector<SemanticDebugPointerExpression> _operands)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Sum;
		result.operands = std::move(_operands);
		return result;
	}

	static SemanticDebugPointerExpression product(
		std::vector<SemanticDebugPointerExpression> _operands
	)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Product;
		result.operands = std::move(_operands);
		return result;
	}

	static SemanticDebugPointerExpression difference(
		SemanticDebugPointerExpression _minuend,
		SemanticDebugPointerExpression _subtrahend
	)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Difference;
		result.operands.emplace_back(std::move(_minuend));
		result.operands.emplace_back(std::move(_subtrahend));
		return result;
	}

	static SemanticDebugPointerExpression quotient(
		SemanticDebugPointerExpression _dividend,
		SemanticDebugPointerExpression _divisor
	)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Quotient;
		result.operands.emplace_back(std::move(_dividend));
		result.operands.emplace_back(std::move(_divisor));
		return result;
	}

	static SemanticDebugPointerExpression remainder(
		SemanticDebugPointerExpression _dividend,
		SemanticDebugPointerExpression _divisor
	)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Remainder;
		result.operands.emplace_back(std::move(_dividend));
		result.operands.emplace_back(std::move(_divisor));
		return result;
	}

	static SemanticDebugPointerExpression keccak256(
		std::vector<SemanticDebugPointerExpression> _operands
	)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Keccak256;
		result.operands = std::move(_operands);
		return result;
	}

	static SemanticDebugPointerExpression concat(
		std::vector<SemanticDebugPointerExpression> _operands
	)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Concat;
		result.operands = std::move(_operands);
		return result;
	}

	static SemanticDebugPointerExpression wordSized(SemanticDebugPointerExpression _operand)
	{
		SemanticDebugPointerExpression result;
		result.kind = Kind::Resize;
		result.operands.emplace_back(std::move(_operand));
		return result;
	}

	static SemanticDebugPointerExpression sized(
		unsigned _bytes,
		SemanticDebugPointerExpression _operand
	)
	{
		// The ethdebug $sized<N> expression requires a positive byte width;
		// use wordSized() for word-sized resizing.
		solAssert(_bytes > 0);
		SemanticDebugPointerExpression result;
		result.kind = Kind::Resize;
		result.value = std::to_string(_bytes);
		result.operands.emplace_back(std::move(_operand));
		return result;
	}
};


/// Internal representation of an ethdebug pointer: a single region of EVM data
/// or a structured collection of sub-pointers. Which fields are meaningful
/// depends on @a pointerClass.
struct SemanticDebugPointer
{
	enum class Class
	{
		/// A single addressed range of data. Uses @a location, @a name, @a slot,
		/// @a offset and @a length.
		Region,
		/// An ordered composition of sub-pointers in @a group.
		Group,
		/// A dynamically sized repetition: @a count elements, the index bound to
		/// @a indexName inside @a listElement.
		List,
		/// A pointer chosen by the non-zero-ness of @a condition: @a thenPointer,
		/// otherwise the optional @a elsePointer.
		Conditional,
		/// A pointer with auxiliary variables: ordered @a definitions bound inside
		/// @a scopeTarget. Later definitions may reference earlier ones.
		Scope,
		/// A reference to a pointer template defined elsewhere: @a templateName,
		/// with produced region names optionally renamed through @a yields.
		/// The template is defined either by an enclosing Templates pointer or
		/// by the pointer template table of the sidecar.
		TemplateReference,
		/// A pointer with locally defined templates: @a templates are available
		/// by name to template references inside @a scopeTarget.
		Templates,
		Unknown
	};

	enum class Location
	{
		Stack,
		Storage,
		Transient,
		Memory,
		Calldata,
		Returndata,
		Code,
		Unknown
	};

	Class pointerClass = Class::Unknown;

	/// Template parameters (the pointer template's `expect` list) that must be
	/// bound externally before this pointer can be evaluated, e.g. mapping
	/// keys. Meaningful on a root pointer and on template definitions, in the
	/// sidecar's pointer table as well as in local `templates` blocks.
	std::vector<std::string> expectedParameters;

	// Class::Region
	std::optional<Location> location;
	std::optional<std::string> name;
	/// Word-oriented locations (stack, storage, transient) address by slot.
	std::optional<SemanticDebugPointerExpression> slot;
	/// Byte offset: within the slot for word-oriented locations, absolute for
	/// byte-oriented ones (memory, calldata, returndata, code).
	std::optional<SemanticDebugPointerExpression> offset;
	/// Byte length of the region.
	std::optional<SemanticDebugPointerExpression> length;

	// Class::Group
	std::vector<SemanticDebugPointer> group;

	// Class::List
	std::optional<SemanticDebugPointerExpression> count;
	std::optional<std::string> indexName;
	std::shared_ptr<SemanticDebugPointer const> listElement;

	// Class::Conditional
	std::optional<SemanticDebugPointerExpression> condition;
	std::shared_ptr<SemanticDebugPointer const> thenPointer;
	std::shared_ptr<SemanticDebugPointer const> elsePointer;

	// Class::Scope and Class::Templates share the target: the `in` pointer.
	std::vector<std::pair<std::string, SemanticDebugPointerExpression>> definitions;
	std::shared_ptr<SemanticDebugPointer const> scopeTarget;

	// Class::TemplateReference
	std::optional<std::string> templateName;
	std::vector<std::pair<std::string, std::string>> yields;

	// Class::Templates
	std::vector<std::pair<std::string, std::shared_ptr<SemanticDebugPointer const>>> templates;

	static SemanticDebugPointer region(
		Location _location,
		std::optional<std::string> _name,
		std::optional<SemanticDebugPointerExpression> _slot,
		std::optional<SemanticDebugPointerExpression> _offset = std::nullopt,
		std::optional<SemanticDebugPointerExpression> _length = std::nullopt
	)
	{
		SemanticDebugPointer result;
		result.pointerClass = Class::Region;
		result.location = _location;
		result.name = std::move(_name);
		result.slot = std::move(_slot);
		result.offset = std::move(_offset);
		result.length = std::move(_length);
		return result;
	}

	static SemanticDebugPointer makeGroup(std::vector<SemanticDebugPointer> _members)
	{
		SemanticDebugPointer result;
		result.pointerClass = Class::Group;
		result.group = std::move(_members);
		return result;
	}

	static SemanticDebugPointer list(
		SemanticDebugPointerExpression _count,
		std::string _indexName,
		SemanticDebugPointer _element
	)
	{
		SemanticDebugPointer result;
		result.pointerClass = Class::List;
		result.count = std::move(_count);
		result.indexName = std::move(_indexName);
		result.listElement = std::make_shared<SemanticDebugPointer const>(std::move(_element));
		return result;
	}

	static SemanticDebugPointer conditional(
		SemanticDebugPointerExpression _condition,
		SemanticDebugPointer _then,
		std::optional<SemanticDebugPointer> _else = std::nullopt
	)
	{
		SemanticDebugPointer result;
		result.pointerClass = Class::Conditional;
		result.condition = std::move(_condition);
		result.thenPointer = std::make_shared<SemanticDebugPointer const>(std::move(_then));
		if (_else)
			result.elsePointer = std::make_shared<SemanticDebugPointer const>(std::move(*_else));
		return result;
	}

	static SemanticDebugPointer scope(
		std::vector<std::pair<std::string, SemanticDebugPointerExpression>> _definitions,
		SemanticDebugPointer _target
	)
	{
		SemanticDebugPointer result;
		result.pointerClass = Class::Scope;
		result.definitions = std::move(_definitions);
		result.scopeTarget = std::make_shared<SemanticDebugPointer const>(std::move(_target));
		return result;
	}

	static SemanticDebugPointer templateReference(
		std::string _templateName,
		std::vector<std::pair<std::string, std::string>> _yields = {}
	)
	{
		SemanticDebugPointer result;
		result.pointerClass = Class::TemplateReference;
		result.templateName = std::move(_templateName);
		result.yields = std::move(_yields);
		return result;
	}

	static SemanticDebugPointer withTemplates(
		std::vector<std::pair<std::string, SemanticDebugPointer>> _templates,
		SemanticDebugPointer _target
	)
	{
		SemanticDebugPointer result;
		result.pointerClass = Class::Templates;
		for (auto& [templateName, definition]: _templates)
			result.templates.emplace_back(
				std::move(templateName),
				std::make_shared<SemanticDebugPointer const>(std::move(definition))
			);
		result.scopeTarget = std::make_shared<SemanticDebugPointer const>(std::move(_target));
		return result;
	}
};

/// One binding introduced by a scope record: the source declaration, its type
/// and, when the value is materialized, the pointer that resolves it.
struct SemanticDebugVariable
{
	/// Source-language identifier, if the variable has one. Unnamed return
	/// parameters are still represented and leave this unset.
	std::optional<std::string> identifier;
	std::optional<int64_t> declarationASTID;
	std::optional<SemanticDebugSourceRange> declarationSourceRange;
	std::optional<std::string> typeID;
	/// Whether the value is materialized, computable or unavailable. A
	/// materialized variable has a pointer; the other phases do not.
	SemanticDebugVariablePhase phase = SemanticDebugVariablePhase::OptimizedOut;
	std::optional<SemanticDebugPointer> pointer;
};

/// Changes a variable's phase or pointer from the carrying Yul node onward,
/// within the variable's scope, until the next update - the analogue of an
/// `llvm.dbg.value` intrinsic. A single per-scope phase and pointer cannot
/// describe a pass that gives one source variable different generated names
/// over its lifetime (SSATransform) or replaces stored values with
/// recomputation (Rematerialiser); this record can, and a Drop is an update to
/// OptimizedOut.
struct SemanticDebugVariableUpdate
{
	/// Declaration AST ID of the variable being updated.
	int64_t variableASTID = 0;
	/// Replacement phase valid from the carrying node onward. Omitted when
	/// only the pointer changes.
	std::optional<SemanticDebugVariablePhase> phase;
	/// Replacement pointer for a materialized value. A change to Computed or
	/// OptimizedOut clears the previous pointer.
	std::optional<SemanticDebugPointer> pointer;
};

/// The semantic scope described by an attached Yul node. On a node that
/// introduces a source scope it defines the scope's variables; on a
/// finer-grained node it carries only variable updates. A variable appears in
/// exactly one scope record; nested records do not repeat enclosing bindings.
struct SemanticDebugScope
{
	using ConstPtr = std::shared_ptr<SemanticDebugScope const>;

	/// Bindings introduced by the scope, in source order.
	std::vector<SemanticDebugVariable> variableDefinitions = {};
	/// Phase or pointer changes taking effect at the node this payload is
	/// attached to. Scope records define variables; statement-level records
	/// update them.
	std::vector<SemanticDebugVariableUpdate> variableUpdates = {};
};

} // namespace solidity::langutil
