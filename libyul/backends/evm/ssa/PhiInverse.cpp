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
	_cfg.forEachUpsilon(_cfg.block(_from), [&](InstId const instId, SSACFG::Inst const& inst) {
		if (
			InstId const phi = _cfg.upsilonPhi(instId);
			_cfg.inst(phi).block == _to
		)
			m_phiToPreImage[phi] = inst.inputs.at(0);
	});
}

bool PhiInverse::noOp() const
{
	return m_phiToPreImage.empty();
}

InstId PhiInverse::operator()(InstId _valueId) const
{
	return solidity::util::valueOrDefault(m_phiToPreImage, _valueId, _valueId);
}

std::map<InstId, InstId> const& PhiInverse::data() const
{
	return m_phiToPreImage;
}
