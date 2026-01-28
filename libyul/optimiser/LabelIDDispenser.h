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

#include <libyul/ASTLabelRegistry.h>

#include <functional>
#include <set>

namespace solidity::yul
{

class Dialect;

/// Can spawn new `LabelID`s which depend on `LabelID`s from a parent label registry. Once generation is completed,
/// a new `ASTLabelRegistry` can be generated based on the used subset of spawned and original IDs.
class LabelIDDispenser
{
public:
	using LabelID = ASTLabelRegistry::LabelID;
	/// A set of reserved labels may be provided, which is excluded when generating new labels. If a reserved label
	/// already appears in the label registry and is used as-is in the AST, it will be reused despite it being
	/// provided here.
	/// Original labels will always be preserved even if they are not valid Yul identifiers.
	explicit LabelIDDispenser(
		ASTLabelRegistry const& _labels,
		std::set<std::string> const& _reserved = {}
	);

	ASTLabelRegistry const& labels() const { return m_labels; }

	/// Spawns a new LabelID which depends on a parent LabelID that will be used for its string representation.
	/// Parent must not be unused. For spawning new ghost labels, `newGhost` must be used.
	LabelID newID(LabelID _parent = 0);
	/// Spawns a new ghost label.
	LabelID newGhost();

	/// Creates a new label registry based on the added labels.
	/// Ghost IDs are always preserved, as these are not referenced in the AST.
	/// Labels are guaranteed to be valid and not reserved if and only if they were valid and not reserved in the
	/// original registry. No new invalid and/or reserved labels are introduced.
	ASTLabelRegistry generateNewLabels(std::set<LabelID> const& _usedIDs, Dialect const& _dialect) const;
	ASTLabelRegistry generateNewLabels(Dialect const& _dialect) const;
private:
	/// For newly added label IDs, this yields the parent ID which is contained in the provided registry.
	/// For label IDs which already are not new, this function is the identity.
	LabelID resolveParentLabelID(LabelID _id) const;
	bool ghost(LabelID _id) const;

	ASTLabelRegistry const& m_labels;
	/// Reserved labels, equipped with the transparent less comparison operator to be able to handle string_view.
	std::set<std::string, std::less<>> m_reservedLabels;
	/// Contains references to parent label IDs. Indices are new IDs offset by `m_labels.maxID() + 1`.
	std::vector<LabelID> m_idToLabelMapping;
};

}
