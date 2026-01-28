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

#include <libyul/optimiser/FunctionCallFinder.h>

#include <libyul/optimiser/ASTWalker.h>
#include <libyul/AST.h>
#include <libyul/Utilities.h>

using namespace solidity;
using namespace solidity::yul;

namespace
{
template<typename Base, typename ResultType>
class MaybeConstFunctionCallFinder: Base
{
public:
	using MaybeConstBlock = std::conditional_t<std::is_const_v<ResultType>, Block const, Block>;
	static std::vector<ResultType*> run(MaybeConstBlock& _block, FunctionHandle const& _functionHandle)
	{
		MaybeConstFunctionCallFinder functionCallFinder(_functionHandle);
		functionCallFinder(_block);
		return functionCallFinder.m_calls;
	}
private:
	explicit MaybeConstFunctionCallFinder(FunctionHandle const& _functionHandle):
		m_functionHandle(_functionHandle), m_calls() {}

	using Base::operator();
	void operator()(ResultType& _functionCall) override
	{
		Base::operator()(_functionCall);
		if (functionNameToHandle(_functionCall.functionName) == m_functionHandle)
			m_calls.emplace_back(&_functionCall);
	}
	FunctionHandle const& m_functionHandle;
	std::vector<ResultType*> m_calls;
};
}

std::vector<FunctionCall*> yul::findFunctionCalls(Block& _block, FunctionHandle const& _functionHandle)
{
	return MaybeConstFunctionCallFinder<ASTModifier, FunctionCall>::run(_block, _functionHandle);
}

std::vector<FunctionCall const*> yul::findFunctionCalls(Block const& _block, FunctionHandle const& _functionHandle)
{
	return MaybeConstFunctionCallFinder<ASTWalker, FunctionCall const>::run(_block, _functionHandle);
}
