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
/** @file Assembly.h
 * @author Gav Wood <i@gavwood.com>
 * @date 2014
 */

#pragma once

#include <libsolutil/Common.h>
#include <libsolutil/FixedHash.h>

namespace solidity::evmasm
{

/**
 * Binary object that potentially still needs to be linked (i.e. addresses of other contracts
 * need to be filled in).
 */
struct LinkerObject
{
	using ImmutableRefs = std::pair<std::string, std::vector<size_t>>;
	/// The bytecode.
	bytes bytecode;

	/// Map from offsets in bytecode to library identifiers. The addresses starting at those offsets
	/// need to be replaced by the actual addresses by the linker.
	std::map<size_t, std::string> linkReferences;

	/// Map from hashes of the identifiers of immutable variables to the full identifier of the immutable and
	/// to a list of offsets into the bytecode that refer to their values.
	std::map<u256, ImmutableRefs> immutableReferences;

	struct InstructionLocation
	{
		/// Absolute position of instruction's opcode within the bytecode.
		/// The opcode takes up exactly one byte and is assumed to be followed by its immediate arguments.
		size_t start{};
		/// Absolute position of the first byte past the end of the instruction, including potential immediate arguments.
		size_t end{};
		/// Index of the AssemblyItem that produced the instruction within the Assembly.
		/// While items of most types generate a single instruction, in general it can be more than one.
		size_t assemblyItemIndex{};
	};
	struct CodeSectionLocation
	{
		/// Absolute position of the first byte belonging to the code section.
		/// Equal to instructionLocations[0].start if the code section is not empty.
		size_t start{};
		/// Absolute position of the first byte past end of the code section.
		/// Greater or equal to start. Must be equal if instructionLocations is empty.
		size_t end{};
		/// Descriptions of all instructions contained within the code section.
		/// The instructions are assumed to fill the whole section, without any gaps or duplicates.
		/// The areas between opcodes are assumed to contain their immediate arguments, of size appropriate for the opcode type.
		/// The arguments of the last instruction extend to the end of the section.
		/// The instructions must be ordered according to their positions (ascending).
		std::vector<InstructionLocation> instructionLocations;
	};
	/// Descriptions of all code sections in the ascending order of their positions.
	/// There are no duplicates and the sections never overlap.
	/// Only sections belonging to the top-level assembly are included, even if the bytecode contains subassemblies.
	std::vector<CodeSectionLocation> codeSectionLocations;

	struct FunctionDebugData
	{
		std::optional<size_t> bytecodeOffset;
		std::optional<size_t> instructionIndex;
		std::optional<size_t> sourceID;
		size_t params = {};
		size_t returns = {};
	};

	/// Bytecode offsets of named tags like function entry points.
	std::map<std::string, FunctionDebugData> functionDebugData;

	/// Appends the bytecode of @a _other and incorporates its link references.
	void append(LinkerObject const& _other);

	/// Links the given libraries by replacing their uses in the code and removes them from the references.
	void link(std::map<std::string, util::h160> const& _libraryAddresses);

	/// @returns a hex representation of the bytecode of the given object, replacing unlinked
	/// addresses by placeholders. This output is lowercase.
	std::string toHex() const;

	/// @returns a 36 character string that is used as a placeholder for the library
	/// address (enclosed by `__` on both sides). The placeholder is the hex representation
	/// of the first 18 bytes of the keccak-256 hash of @a _libraryName.
	static std::string libraryPlaceholder(std::string const& _libraryName);

	bool operator<(LinkerObject const& _other) const;

private:
	static util::h160 const* matchLibrary(
		std::string const& _linkRefName,
		std::map<std::string, util::h160> const& _libraryAddresses
	);
};

}
