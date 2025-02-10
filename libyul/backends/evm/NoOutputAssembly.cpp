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
 * Assembly interface that ignores everything. Can be used as a backend for a compilation dry-run.
 */

#include <libyul/backends/evm/NoOutputAssembly.h>

#include <libyul/AST.h>
#include <libyul/Exceptions.h>

#include <libevmasm/Instruction.h>

#include <range/v3/view/iota.hpp>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::util;
using namespace solidity::langutil;

namespace
{

void modifyBuiltinToNoOutput(BuiltinFunctionForEVM& _builtin)
{
	_builtin.generateCode = [_builtin](FunctionCall const& _call, AbstractAssembly& _assembly, BuiltinContext&)
	{
		for (size_t i: ranges::views::iota(0u, _call.arguments.size()))
			if (!_builtin.literalArgument(i))
				_assembly.appendInstruction(evmasm::Instruction::POP);

		for (size_t i = 0; i < _builtin.numReturns; i++)
			_assembly.appendConstant(u256(0));
	};
}

}

void NoOutputAssembly::appendInstruction(evmasm::Instruction _instr)
{
	m_stackHeight += instructionInfo(_instr, m_evmVersion).ret - instructionInfo(_instr, m_evmVersion).args;
}

void NoOutputAssembly::appendConstant(u256 const&)
{
	appendInstruction(evmasm::pushInstruction(1));
}

void NoOutputAssembly::appendLabel(LabelID)
{
	appendInstruction(evmasm::Instruction::JUMPDEST);
}

void NoOutputAssembly::appendLabelReference(LabelID)
{
	appendInstruction(evmasm::pushInstruction(1));
}

NoOutputAssembly::LabelID NoOutputAssembly::newLabelId()
{
	return 1;
}

AbstractAssembly::LabelID NoOutputAssembly::namedLabel(std::string const&, size_t, size_t, std::optional<size_t>)
{
	return 1;
}

void NoOutputAssembly::appendLinkerSymbol(std::string const&)
{
	yulAssert(false, "Linker symbols not yet implemented.");
}

void NoOutputAssembly::appendVerbatim(bytes, size_t _arguments, size_t _returnVariables)
{
	m_stackHeight += static_cast<int>(_returnVariables) - static_cast<int>(_arguments);
}

void NoOutputAssembly::appendJump(int _stackDiffAfter, JumpType)
{
	appendInstruction(evmasm::Instruction::JUMP);
	m_stackHeight += _stackDiffAfter;
}

void NoOutputAssembly::appendJumpTo(LabelID _labelId, int _stackDiffAfter, JumpType _jumpType)
{
	appendLabelReference(_labelId);
	appendJump(_stackDiffAfter, _jumpType);
}

void NoOutputAssembly::appendJumpToIf(LabelID _labelId, JumpType)
{
	appendLabelReference(_labelId);
	appendInstruction(evmasm::Instruction::JUMPI);
}

void NoOutputAssembly::appendAssemblySize()
{
	appendInstruction(evmasm::Instruction::PUSH1);
}

void NoOutputAssembly::appendDupN(size_t)
{
	m_stackHeight++;
}

std::pair<std::shared_ptr<AbstractAssembly>, AbstractAssembly::SubID> NoOutputAssembly::createSubAssembly(bool, std::string)
{
	yulAssert(false, "Sub assemblies not implemented.");
	return {};
}

AbstractAssembly::FunctionID NoOutputAssembly::registerFunction(uint8_t _args, uint8_t _rets, bool)
{
	yulAssert(m_context.numFunctions <= std::numeric_limits<AbstractAssembly::FunctionID>::max());
	AbstractAssembly::FunctionID id = static_cast<AbstractAssembly::FunctionID>(m_context.numFunctions++);
	m_context.functionSignatures[id] = {_args, _rets};
	return id;
}

void NoOutputAssembly::beginFunction(FunctionID _functionID)
{
	yulAssert(m_currentFunctionID == 0, "Attempted to begin a function before ending the last one.");
	yulAssert(m_context.functionSignatures.count(_functionID) == 1, "Filling unregistered function.");
	yulAssert(m_stackHeight == 0, "Non-empty stack on beginFunction call.");
	m_currentFunctionID = _functionID;
}

void NoOutputAssembly::endFunction()
{
	yulAssert(m_currentFunctionID != 0, "End function without begin function.");
	auto const [_, rets] = m_context.functionSignatures.at(m_currentFunctionID);
	yulAssert(m_stackHeight == rets, "Stack height mismatch at function end.");
	m_currentFunctionID = 0;
}

void NoOutputAssembly::appendFunctionCall(FunctionID _functionID)
{
	auto [args, rets] = m_context.functionSignatures.at(_functionID);
	m_stackHeight += static_cast<int>(rets) - static_cast<int>(args);
	solAssert(m_stackHeight >= 0);
}

void NoOutputAssembly::appendFunctionReturn()
{
	yulAssert(m_currentFunctionID != 0, "End function without begin function.");
	auto const [_, rets] = m_context.functionSignatures.at(m_currentFunctionID);
	yulAssert(m_stackHeight == rets, "Stack height mismatch at function end.");
}

void NoOutputAssembly::appendDataOffset(std::vector<AbstractAssembly::SubID> const&)
{
	appendInstruction(evmasm::Instruction::PUSH1);
}

void NoOutputAssembly::appendDataSize(std::vector<AbstractAssembly::SubID> const&)
{
	appendInstruction(evmasm::Instruction::PUSH1);
}

AbstractAssembly::SubID NoOutputAssembly::appendData(bytes const&)
{
	return 1;
}


void NoOutputAssembly::appendImmutable(std::string const&)
{
	yulAssert(false, "loadimmutable not implemented.");
}

void NoOutputAssembly::appendImmutableAssignment(std::string const&)
{
	yulAssert(false, "setimmutable not implemented.");
}

void NoOutputAssembly::appendAuxDataLoadN(uint16_t)
{
	yulAssert(false, "auxdataloadn not implemented.");
}

void NoOutputAssembly::appendEOFCreate(ContainerID)
{
	yulAssert(false, "eofcreate not implemented.");

}
void NoOutputAssembly::appendReturnContract(ContainerID)
{
	yulAssert(false, "returncontract not implemented.");
}

NoOutputEVMDialect::NoOutputEVMDialect(EVMDialect const& _copyFrom):
	EVMDialect(_copyFrom.evmVersion(), _copyFrom.eofVersion(), _copyFrom.providesObjectAccess())
{
	for (auto& fun: m_functions)
		if (fun)
			modifyBuiltinToNoOutput(*fun);
}

BuiltinFunctionForEVM const& NoOutputEVMDialect::builtin(BuiltinHandle const& _handle) const
{
	if (isVerbatimHandle(_handle))
		// for verbatims the modification is performed lazily as they are stored in a lookup table fashion
		if (
			auto& builtin = m_verbatimFunctions[_handle.id];
			!builtin
		)
		{
			builtin = std::make_unique<BuiltinFunctionForEVM>(createVerbatimFunctionFromHandle(_handle));
			modifyBuiltinToNoOutput(*builtin);
		}
	return EVMDialect::builtin(_handle);
}
