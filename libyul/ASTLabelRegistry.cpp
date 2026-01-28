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

#include <libyul/ASTLabelRegistry.h>

#include <libyul/Exceptions.h>

#include <fmt/format.h>

using namespace solidity::yul;

ASTLabelRegistry::ASTLabelRegistry(): m_labels{""}, m_idToLabelMapping{0} {}

ASTLabelRegistry::ASTLabelRegistry(std::vector<std::string> _labels, std::vector<size_t> _idToLabelMapping):
	m_labels(std::move(_labels)),
	m_idToLabelMapping(std::move(_idToLabelMapping))
{
	yulAssert(!m_labels.empty());
	yulAssert(m_labels[0].empty());
	yulAssert(!m_idToLabelMapping.empty());
	yulAssert(m_idToLabelMapping[0] == 0);
	// using vector<uint8_t> over vector<bool>, as the latter is optimized for space-efficiency
	std::vector<uint8_t> labelVisited (m_labels.size(), false);
	size_t numLabels = 0;
	for (auto const& labelIndex: m_idToLabelMapping)
	{
		if (labelIndex == ghostLabelIndex())
			continue;
		yulAssert(labelIndex < m_labels.size());
		// it is possible to have multiple references to the empty label index
		// only the id == 0 refers to an actually empty label, otherwise the LabelID is unused
		yulAssert(
			labelIndex == 0 || !labelVisited[labelIndex],
			fmt::format("LabelID {} (label \"{}\") is not unique.", labelIndex, m_labels[labelIndex])
		);
		labelVisited[labelIndex] = true;
		if (labelIndex >= 1)
			++numLabels;
	}
	yulAssert(numLabels + 1 == m_labels.size(), "Unreferenced labels present.");
}

ASTLabelRegistry::LabelID ASTLabelRegistry::maxID() const
{
	yulAssert(!m_idToLabelMapping.empty());
	return m_idToLabelMapping.size() - 1;
}

size_t ASTLabelRegistry::idToLabelIndex(LabelID const _id) const
{
	yulAssert(_id < m_idToLabelMapping.size());
	return m_idToLabelMapping[_id];
}

std::string_view ASTLabelRegistry::operator[](LabelID const _id) const
{
	auto const labelIndex = idToLabelIndex(_id);
	yulAssert(labelIndex != ghostLabelIndex(), "Ghost ids are not explicitly labelled in the registry.");
	// not using `unused` here, as we already have evaluated the label index
	// an id is unused if it is not id == 0 (empty label) but points at label index 0
	yulAssert(empty(_id) || labelIndex != 0, "Can only query ids that are not unused");
	return m_labels[labelIndex];
}

bool ASTLabelRegistry::ghost(LabelID const _id) const
{
	return idToLabelIndex(_id) == ghostLabelIndex();
}

bool ASTLabelRegistry::unused(LabelID const _id) const
{
	return !empty(_id) && idToLabelIndex(_id) == 0;
}

std::optional<ASTLabelRegistry::LabelID> ASTLabelRegistry::findIDForLabel(std::string_view const _label) const
{
	for (LabelID id = 0; id <= maxID(); ++id)
		if ((*this)[id] == _label)
			return id;
	return std::nullopt;
}

std::tuple<ASTLabelRegistry::LabelID, bool> ASTLabelRegistryBuilder::DefinedLabels::tryInsert(
	std::string_view const _label,
	ASTLabelRegistry::LabelID const _id
)
{
	auto const [it, emplaced] = m_labelToIDMapping.try_emplace(std::string{_label}, _id);
	return std::make_tuple(it->second, emplaced);
}

ASTLabelRegistryBuilder::ASTLabelRegistryBuilder():
	m_nextID(1)
{}

ASTLabelRegistryBuilder::ASTLabelRegistryBuilder(ASTLabelRegistry const& _existingRegistry)
{
	yulAssert(!_existingRegistry.labels().empty() && _existingRegistry[0].empty());
	for (size_t id = 1; id <= _existingRegistry.maxID(); ++id)
	{
		if (!ASTLabelRegistry::empty(id) && !_existingRegistry.unused(id))
		{
			// ghost ids are not added to the map as they are not explicitly labeled
			if (_existingRegistry.ghost(id))
				m_ghosts.push_back(id);
			else
			{
				auto const [_, inserted] = m_definedLabels.tryInsert(_existingRegistry[id], id);
				yulAssert(inserted, "Existing registry cannot contain duplicate labels.");
			}
		}
	}
	m_nextID = _existingRegistry.maxID() + 1;
}

ASTLabelRegistry::LabelID ASTLabelRegistryBuilder::define(std::string_view const _label)
{
	auto const [id, inserted] = m_definedLabels.tryInsert(_label, m_nextID);
	if (inserted)
		m_nextID++;
	return id;
}

ASTLabelRegistry::LabelID ASTLabelRegistryBuilder::addGhost()
{
	m_ghosts.push_back(m_nextID);
	return m_nextID++;
}

ASTLabelRegistry ASTLabelRegistryBuilder::build() const
{
	auto const& labelToIDMapping = m_definedLabels.labelToIDMapping();
	yulAssert(labelToIDMapping.contains(""));
	yulAssert(labelToIDMapping.at("") == 0);

	std::vector<std::string> labels{""};
	labels.reserve(labelToIDMapping.size());
	std::vector<size_t> idToLabelMapping( m_nextID + 1, 0);
	yulAssert(!idToLabelMapping.empty(), "Mapping must at least contain empty label");
	for (auto const& [label, id]: labelToIDMapping)
	{
		if (ASTLabelRegistry::empty(id))
			continue;

		labels.emplace_back(label);
		idToLabelMapping[id] = labels.size() - 1;
	}
	for (auto const ghostId: m_ghosts)
		idToLabelMapping[ghostId] = ASTLabelRegistry::ghostLabelIndex();
	return ASTLabelRegistry{std::move(labels), std::move(idToLabelMapping)};
}
