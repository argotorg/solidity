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

#include <libyul/backends/evm/ssa/SSACFGTypes.h>

#include <liblangutil/DebugData.h>
#include <libyul/Exceptions.h>

#include <vector>

namespace solidity::yul::ssa
{

/// Stores debug data for all SSACFG entities in parallel arrays indexed by the entities' stable IDs.
struct SSACFGDebugInfo
{
	void setBlockDebugData(BlockId _id, langutil::DebugData::ConstPtr _data)
	{
		yulAssert(_id.hasValue());
		ensureSize(m_blockDebugData, _id.value);
		m_blockDebugData[_id.value] = std::move(_data);
	}

	langutil::DebugData::ConstPtr const& blockDebugData(BlockId _id) const
	{
		return getOrEmpty(m_blockDebugData, _id.value);
	}

	void setExitDebugData(BlockId _id, langutil::DebugData::ConstPtr _data)
	{
		yulAssert(_id.hasValue());
		ensureSize(m_exitDebugData, _id.value);
		m_exitDebugData[_id.value] = std::move(_data);
	}

	langutil::DebugData::ConstPtr const& exitDebugData(BlockId _id) const
	{
		return getOrEmpty(m_exitDebugData, _id.value);
	}

	void setOperationDebugData(OperationId _id, langutil::DebugData::ConstPtr _data)
	{
		yulAssert(_id.hasValue());
		ensureSize(m_operationDebugData, _id.value);
		m_operationDebugData[_id.value] = std::move(_data);
	}

	langutil::DebugData::ConstPtr const& operationDebugData(OperationId _id) const
	{
		return getOrEmpty(m_operationDebugData, _id.value);
	}

	void setValueDebugData(ValueId _id, langutil::DebugData::ConstPtr _data)
	{
		yulAssert(_id.hasValue());
		auto& vec = vectorForKind(_id.kind());
		ensureSize(vec, _id.value());
		vec[_id.value()] = std::move(_data);
	}

	langutil::DebugData::ConstPtr const& valueDebugData(ValueId _id) const
	{
		return getOrEmpty(vectorForKind(_id.kind()), _id.value());
	}

	/// Top-level debug data for the SSACFG (e.g. the function definition's debug data).
	langutil::DebugData::ConstPtr graphDebugData;

private:
	static void ensureSize(std::vector<langutil::DebugData::ConstPtr>& _vec, std::size_t const _index)
	{
		if (_vec.size() <= _index)
			_vec.resize(_index + 1);
	}

	static langutil::DebugData::ConstPtr const& getOrEmpty(
		std::vector<langutil::DebugData::ConstPtr> const& _debugData,
		std::size_t const _index
	)
	{
		static langutil::DebugData::ConstPtr const empty{nullptr};
		if (_index >= _debugData.size())
			return empty;
		return _debugData[_index];
	}

	std::vector<langutil::DebugData::ConstPtr>& vectorForKind(ValueId::Kind const _kind)
	{
		switch (_kind)
		{
		case ValueId::Kind::Literal: return m_literalDebugData;
		case ValueId::Kind::Variable: return m_variableDebugData;
		case ValueId::Kind::Phi: return m_phiDebugData;
		default: yulAssert(false, "No debug data for unreachable values.");
		}
	}
	std::vector<langutil::DebugData::ConstPtr> const& vectorForKind(ValueId::Kind const _kind) const
	{
		switch (_kind)
		{
		case ValueId::Kind::Literal: return m_literalDebugData;
		case ValueId::Kind::Variable: return m_variableDebugData;
		case ValueId::Kind::Phi: return m_phiDebugData;
		default: yulAssert(false, "No debug data for unreachable values.");
		}
	}

	std::vector<langutil::DebugData::ConstPtr> m_blockDebugData;
	std::vector<langutil::DebugData::ConstPtr> m_exitDebugData;
	std::vector<langutil::DebugData::ConstPtr> m_operationDebugData;
	std::vector<langutil::DebugData::ConstPtr> m_literalDebugData;
	std::vector<langutil::DebugData::ConstPtr> m_variableDebugData;
	std::vector<langutil::DebugData::ConstPtr> m_phiDebugData;
};

}
