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
/// The pointer templates of ethdebug/format/info/resources, derived from the
/// layouts of the types of the frontend.

#pragma once

#include <libsolidity/ast/ASTForward.h>

#include <liblangutil/EthdebugSchema.h>

#include <map>
#include <set>
#include <string>
#include <utility>
#include <vector>

namespace solidity::frontend
{
enum class DataLocation;
class Type;
class ArrayType;
class MappingType;
class StructType;
}

namespace solidity::frontend::ethdebug
{

/// Pointer templates keyed by layout and canonical type identifier. Storage
/// and transient templates expect `slot` as a parameter; value types also
/// expect `offset` as a parameter: the little-endian byte offset, counted
/// from the least significant byte. Memory and calldata templates expect
/// `offset` as a parameter: the byte address of the value's data (including
/// a dynamic array's length word). A mapping also expects `key` as a parameter.
/// A mapping nested in another type is the region of its base slot,
/// from which the mapping's own template locates the entries, so that a
/// recursive type expects one key per mapping level a consumer
/// descends, rather than a list of keys the template would have to fix.
///
/// The region names a template produces are relative to the value it
/// describes: a struct's members by their names, an array's elements `item`,
/// the parts of a storage `bytes` or `string` `length-flag`, `long-length` and
/// `data`, and those in memory or calldata `length` and `data`.
/// A template referencing another prefixes the names that one produces with
/// the member or element it describes, so that `from-x` and `to-x` tell the
/// two `Point` members of a `Line` apart.
///
/// Templates reference each other by name, including recursive types,
/// so recursive types do not create C++ ownership cycles.
class PointerTemplateRegistry
{
public:
	/// Registers @a _type and its components in @a _location.
	void registerType(Type const& _type, DataLocation _location);
	/// Registers located reference and mapping variables below @a _node.
	/// Declarations without an implementation do not contribute layouts.
	void registerVariableTypes(ASTNode const& _node);

	/// The pointer ID for a layout of the location-independent type document.
	static std::string identifier(Type const& _type, DataLocation _location);

	std::map<std::string, langutil::ethdebug::schema::Pointer::Template> takeTemplates();

private:
	using Pointer = langutil::ethdebug::schema::Pointer;

	/// Template data and region names retained until takeTemplates().
	struct TemplateDraft
	{
		/// Parameters to bind when instantiating this template.
		std::vector<std::string> expectedParameters;
		Pointer body;
		/// The region names the body produces, for the references to prefix.
		std::set<std::string> producedRegions;
	};

	/// Collects template types reachable from @a _type that still need building.
	void collectTemplateTypes(Type const& _type, DataLocation _location);

	TemplateDraft buildTemplate(Type const& _type, DataLocation _location);
	TemplateDraft buildByteAddressedTemplate(Type const& _type, DataLocation _location);
	Pointer buildByteAddressedArrayDataPointer(
		ArrayType const& _arrayType,
		DataLocation _location,
		std::set<std::string>& _producedRegions
	);
	/// @a _headAddress is the component's head address; @a _abiOffsetBase is the ABI offset base.
	Pointer buildByteAddressedComponentPointer(
		Type const& _type,
		DataLocation _location,
		Pointer::Expression _headAddress,
		Pointer::Expression _abiOffsetBase,
		std::string const& _name,
		std::set<std::string>& _producedRegions
	);
	Pointer buildTemplateReference(
		Type const& _type,
		DataLocation _location,
		std::string const& _name,
		std::set<std::string>& _producedRegions
	);

	/// The pointer of a value of @a _type at @a _slot that is part of another
	/// value: the member of a struct, the element of an array or the value of a
	/// mapping, called @a _name. @a _littleEndianOffset is the little-endian
	/// byte offset of the value in its slot, as in the storage layout.
	/// It must be less than 32 and zero for reference types.
	/// The region names it produces are added to @a _producedRegions.
	Pointer buildStorageComponentPointer(
		Type const& _type,
		Pointer::Expression _slot,
		unsigned _littleEndianOffset,
		std::string const& _name,
		std::set<std::string>& _producedRegions
	);

	/// The members of a struct at their slot offsets and little-endian byte
	/// offsets, using the storage layouts of the member types.
	TemplateDraft buildStructTemplate(StructType const& _structType);

	TemplateDraft buildArrayTemplate(ArrayType const& _arrayType);

	/// The value of the entry for `key` lives at `keccak256(pad(key) . slot)`.
	TemplateDraft buildMappingTemplate(MappingType const& _mappingType);

	/// Dynamic arrays store their element count in the base slot and their data
	/// starting at `keccak256(slot)`.
	Pointer buildDynamicArrayPointer(ArrayType const& _arrayType, std::set<std::string>& _producedRegions);

	/// A list of element pointers laid out from @a _dataStartSlot, each called
	/// `item`. Value-type elements narrower than a word are packed multiple to
	/// a slot from its least significant byte; everything else advances in
	/// whole slots.
	Pointer buildArrayElementListPointer(
		ArrayType const& _arrayType,
		Pointer::Expression _dataStartSlot,
		Pointer::Expression _elementCount,
		std::set<std::string>& _producedRegions
	);

	/// `bytes` and `string` have short and long encodings: short values keep their
	/// data in the base slot with the doubled length in the last byte; long
	/// values keep `2 * length + 1` in the base slot and their data starting at
	/// `keccak256(slot)`. Either way the data is the region `data`.
	Pointer buildBytesOrStringPointer(std::set<std::string>& _producedRegions);

	std::map<std::string, TemplateDraft> m_templateDrafts;
	/// Reachable layouts awaiting construction, ordered by pointer ID.
	std::map<std::string, std::pair<Type const*, DataLocation>> m_pendingTemplateTypes;
	/// IDs of templates being built, so that a recursive type
	/// references its own template instead of building it again.
	std::set<std::string> m_templateIDsBeingBuilt;
};

}
