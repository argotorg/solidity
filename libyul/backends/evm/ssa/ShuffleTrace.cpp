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

#include <libyul/backends/evm/ssa/ShuffleTrace.h>

#include <libyul/backends/evm/ssa/Stack.h>

namespace solidity::yul::ssa
{

void apply(StackData& _data, ShuffleOp const& _op)
{
	Stack stack(_data);
	switch (_op.kind)
	{
	case ShuffleOp::Kind::Swap:
		yulAssert(1 <= _op.depth && _op.depth <= reachableStackDepth, "malformed swap in shuffle trace");
		stack.swap(StackDepth{_op.depth});
		return;
	case ShuffleOp::Kind::Dup:
		yulAssert(1 <= _op.depth && _op.depth <= reachableStackDepth, "malformed dup in shuffle trace");
		stack.dup(StackDepth{static_cast<std::size_t>(_op.depth) - 1});
		return;
	case ShuffleOp::Kind::Pop:
		stack.pop();
		return;
	case ShuffleOp::Kind::Push:
	case ShuffleOp::Kind::Load:
		stack.push(_op.slot);
		return;
	case ShuffleOp::Kind::Store:
		yulAssert(!_data.empty() && _data.back() == _op.slot, "store must consume its value from the stack top");
		stack.pop();
		return;
	}
	solidity::util::unreachable();
}

void replay(StackData& _data, ShuffleTrace const& _trace)
{
	for (ShuffleOp const& op: _trace)
		apply(_data, op);
}

}
