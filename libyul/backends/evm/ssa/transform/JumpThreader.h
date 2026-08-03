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
 * Merges a block ending in an unconditional jump into its unique successor.
 */
#pragma once

namespace solidity::yul::ssa
{

class SSACFG;

namespace transform
{
/// Merges every block that ends in an unconditional Jump into its target whenever that target has the
/// block as its only predecessor, collapsing straight-line chains into a single block. Assumes trivial
/// phis have already been eliminated (so single-predecessor blocks carry no phis).
///
/// Preconditions:
///		- Blocks with a single predecessor do not contain phis, i.e., trivial phi elimination has run
void threadJumps(SSACFG& _cfg);
}

}
