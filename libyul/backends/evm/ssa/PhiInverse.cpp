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

#include <libyul/backends/evm/ssa/PhiInverse.h>

using namespace solidity::yul::ssa;

PhiInverse::PhiInverse(SSACFG const& _cfg, SSACFG::BlockId const& _from, SSACFG::BlockId const& _to)
{
	auto const argIndex = _cfg.phiArgumentIndex(_from, _to);
	for (auto const& phiId: _cfg.block(_to).phis)
	{
		auto const& phiInfo = _cfg.phiInfo(phiId);
		m_phiToPreImage[phiId] = phiInfo.arguments[argIndex];
	}
}

bool PhiInverse::noOp() const
{
	return m_phiToPreImage.empty();
}

SSACFG::ValueId PhiInverse::operator()(SSACFG::ValueId _valueId) const
{
	return util::valueOrDefault(m_phiToPreImage, _valueId, _valueId);
}

std::map<SSACFG::ValueId, SSACFG::ValueId> const& PhiInverse::data() const
{
	return m_phiToPreImage;
}
