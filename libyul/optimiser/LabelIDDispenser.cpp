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

#include <libyul/optimiser/LabelIDDispenser.h>

#include <libyul/optimiser/OptimizerUtilities.h>

#include <fmt/compile.h>

#include <range/v3/range/conversion.hpp>
#include <range/v3/view/filter.hpp>
#include <range/v3/view/iota.hpp>

using namespace solidity::yul;

namespace
{
bool isInvalidLabel(
	std::string_view const _label,
	std::set<std::string, std::less<>> const& _reservedLabels,
	Dialect const& _dialect
)
{
	return isRestrictedIdentifier(_dialect, _label) || _reservedLabels.contains(_label);
}
}

LabelIDDispenser::LabelIDDispenser(ASTLabelRegistry const& _labels, std::set<std::string> const& _reservedLabels):
	m_labels(_labels),
	m_reservedLabels(_reservedLabels.begin(), _reservedLabels.end())
{}

LabelIDDispenser::LabelID LabelIDDispenser::newID(LabelID const _parent)
{
	auto const parentLabelID = resolveParentLabelID(_parent);
	yulAssert(!m_labels.ghost(parentLabelID), "Use newGhost to add new ghosts.");
	m_idToLabelMapping.push_back(parentLabelID);
	return m_idToLabelMapping.size() + m_labels.maxID();
}

LabelIDDispenser::LabelID LabelIDDispenser::newGhost()
{
	m_idToLabelMapping.push_back(ASTLabelRegistry::ghostLabelIndex());
	return m_idToLabelMapping.size() + m_labels.maxID();
}

LabelIDDispenser::LabelID LabelIDDispenser::resolveParentLabelID(LabelID _id) const
{
	yulAssert(_id < m_idToLabelMapping.size() + m_labels.maxID() + 1, "ID exceeds bounds.");
	// bigger than maxID means that the input label id was spawned by this dispenser
	if (_id > m_labels.maxID())
		_id = m_idToLabelMapping[_id - m_labels.maxID() - 1];
	yulAssert(
		_id <= m_labels.maxID() && !m_labels.unused(_id),
		"We can have at most one level of indirection and the derived-from label cannot be unused."
	);
	return _id;
}

bool LabelIDDispenser::ghost(LabelID const _id) const
{
	yulAssert(_id < m_idToLabelMapping.size() + m_labels.maxID() + 1, "ID exceeds bounds.");
	if (_id > m_labels.maxID())
		return m_idToLabelMapping[_id - m_labels.maxID() - 1] == ASTLabelRegistry::ghostLabelIndex();

	return m_labels.ghost(_id);
}

ASTLabelRegistry LabelIDDispenser::generateNewLabels(Dialect const& _dialect) const
{
	auto const usedIDs =
		ranges::views::iota(static_cast<size_t>(1), m_idToLabelMapping.size() + m_labels.maxID() + 1) |
		ranges::to<std::set>;
	return generateNewLabels(usedIDs, _dialect);
}

ASTLabelRegistry LabelIDDispenser::generateNewLabels(std::set<LabelID> const& _usedIDs, Dialect const& _dialect) const
{
	if (_usedIDs.empty())
		return {};

	auto const& originalLabels = m_labels.labels();

	std::vector<uint8_t> reusedLabels (originalLabels.size());
	// this means that everything that is derived from empty needs to be generated
	reusedLabels[0] = true;

	// start with the empty label
	std::vector<std::string> labels{""};
	labels.reserve(originalLabels.size()+1);

	// 0 maps to ""
	yulAssert(!_usedIDs.empty());
	std::vector<size_t> idToLabelMap (*std::prev(_usedIDs.end()) + 1);

	std::set<std::string, std::less<>> alreadyDefinedLabels = m_reservedLabels;

	// we record which labels have to be newly generated, some we can just take over from the existing registry
	std::vector<LabelID> toGenerate;
	for (auto const& id: _usedIDs)
	{
		if (ghost(id))
		{
			idToLabelMap[id] = ASTLabelRegistry::ghostLabelIndex();
			continue;
		}

		auto const parentLabelID = resolveParentLabelID(id);

		auto const originalLabelIndex = m_labels.idToLabelIndex(parentLabelID);
		std::string const& originalLabel = originalLabels[originalLabelIndex];

		// It is important that the used ids are in ascending order to ensure that ids which occur in the provided AST
		// and have unchanged IDs will have their labels reused first, before anything derived from it gets assigned
		// said label.
		static_assert(std::is_same_v<std::decay_t<decltype(_usedIDs)>, std::set<LabelID>>);

		// if we haven't already reused the label, check that either the id didn't change, then we can just
		// take over the old label, otherwise check that it is a valid label and then reuse
		if (!reusedLabels[originalLabelIndex] && (parentLabelID == id || !isInvalidLabel(originalLabel, m_reservedLabels, _dialect)))
		{
			labels.push_back(originalLabel);
			idToLabelMap[id] = labels.size() - 1;
			alreadyDefinedLabels.insert(originalLabel);
			reusedLabels[originalLabelIndex] = true;
		}
		else
			toGenerate.push_back(id);
	}

	std::vector<size_t> labelSuffixes(m_labels.maxID() + 1, 1);
	for (auto const& id: toGenerate)
	{
		yulAssert(!ghost(id));

		auto const parentLabelID = resolveParentLabelID(id);
		auto const parentLabelIndex = m_labels.idToLabelIndex(parentLabelID);
		auto const& parentLabel = originalLabels[parentLabelIndex];

		std::string generatedLabel = parentLabel;
		do
		{
			generatedLabel = format(FMT_COMPILE("{}_{}"), parentLabel, labelSuffixes[parentLabelID]++);
		} while (isInvalidLabel(generatedLabel, alreadyDefinedLabels, _dialect));

		labels.push_back(generatedLabel);
		idToLabelMap[id] = labels.size() - 1;
		alreadyDefinedLabels.insert(generatedLabel);
	}

	return ASTLabelRegistry{std::move(labels), std::move(idToLabelMap)};
}
