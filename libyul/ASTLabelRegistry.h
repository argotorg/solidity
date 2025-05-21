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

#include <limits>
#include <map>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace solidity::yul
{

/// Instances of the `ASTLabelRegistry` are immutable containers describing a labelling of nodes inside the AST.
/// Each element of the AST that possesses a label has a `ASTLabelRegistry::LabelID`, with which the label can
/// be queried in O(1).
/// Preferred way of creating instances is via `ASTLabelRegistryBuilder` when parsing/importing and
/// via `LabelIDDispenser` during/after optimization.
/// Note: The id == 0 always corresponds to the empty label. Other ids can point at the label index 0, which means that
/// they are unused. To check, whether an id is unused, the `unused` function can be used.
/// Note: There is a special case of ghost ids, which are added during CFG construction.
/// They do not directly correspond to elements of an AST but live inside the CFG. They are assigned the
/// special `std::numeric_limits<LabelID>::max` label index. The labels themselves are - if required - generated from
/// the CFG.
class ASTLabelRegistry
{
public:
	/// unsafe to use from a different registry instance, it is up to the user to safeguard against this
	using LabelID = size_t;

	ASTLabelRegistry();
	ASTLabelRegistry(std::vector<std::string> _labels, std::vector<size_t> _idToLabelMapping);

	std::string_view operator[](LabelID _id) const;

	static bool constexpr empty(LabelID const _id) { return _id == emptyID(); }
	static LabelID constexpr emptyID() { return 0; }
	static size_t constexpr ghostLabelIndex() { return std::numeric_limits<size_t>::max(); }

	bool unused(LabelID _id) const;
	bool ghost(LabelID _id) const;
	std::vector<std::string> const& labels() const { return m_labels; }
	LabelID maxID() const;

	size_t idToLabelIndex(LabelID _id) const;
	/// this is a potentially expensive operation
	std::optional<LabelID> findIDForLabel(std::string_view _label) const;

private:
	/// All Yul AST labels present in the registry.
	/// Always contains at least an empty label which also serves as a null-state for non-contiguous ID ranges.
	/// All items must be unique.
	std::vector<std::string> const m_labels;

	/// Assignment of labels to `LabelID`s. Indices are `LabelID`s and values are indices into `m_labels`.
	/// Every label except empty always has exactly one `LabelID` pointing at it.
	/// The empty label has one canonical ID, but unused IDs point to it as well.
	std::vector<size_t> const m_idToLabelMapping;
};

/// Produces instances of `ASTLabelRegistry`. Preferably used during parsing/importing.
class ASTLabelRegistryBuilder
{
public:
	ASTLabelRegistryBuilder();
	/// Creates a new builder taking an already existing label registry into account.
	/// Unused IDs are skipped, ghost IDs are recorded and inserted back into the newly built registry.
	explicit ASTLabelRegistryBuilder(ASTLabelRegistry const& _existingRegistry);

	ASTLabelRegistry::LabelID define(std::string_view _label);
	ASTLabelRegistry::LabelID addGhost();

	/// Creates a new label registry based on what was defined and potentially an existing registry. If such registry
	/// was provided, all labels (including unused and ghost label IDs) carry over.
	ASTLabelRegistry build() const;

private:
	class DefinedLabels
	{
	public:
		std::tuple<ASTLabelRegistry::LabelID, bool> tryInsert(std::string_view _label, ASTLabelRegistry::LabelID _id);
		auto const& labelToIDMapping() const { return m_labelToIDMapping; }

	private:
		std::map<std::string, size_t, std::less<>> m_labelToIDMapping = {{"", 0}};
	};

	DefinedLabels m_definedLabels;
	std::vector<ASTLabelRegistry::LabelID> m_ghosts;
	size_t m_nextID{};
};

}
