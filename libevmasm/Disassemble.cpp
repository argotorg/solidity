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

#include <libevmasm/Disassemble.h>

#include <libsolutil/Common.h>
#include <libsolutil/CommonIO.h>
#include <functional>

using namespace solidity;
using namespace solidity::util;
using namespace solidity::evmasm;

namespace
{

bool isValidDupSwapNImmediate(uint8_t _immediate)
{
	return _immediate <= 0x5a || _immediate >= 0x80;
}

size_t decodeDupSwapNImmediate(uint8_t _immediate)
{
	solAssert(isValidDupSwapNImmediate(_immediate));
	return static_cast<uint8_t>(_immediate + 145);
}

bool isValidMaybeAdditional(Instruction _instr, uint8_t _immediate, langutil::EVMVersion _evmVersion)
{
	switch (_instr)
	{
	case Instruction::DUPN:
	case Instruction::SWAPN:
		return _evmVersion.hasDupSwapN() && isValidDupSwapNImmediate(_immediate);
	default:
		return false;
	}
}

}

void solidity::evmasm::eachInstruction(
	bytes const& _mem,
	langutil::EVMVersion _evmVersion,
	std::function<void(Instruction,u256 const&, int)> const& _onInstruction
)
{
	for (auto it = _mem.begin(); it < _mem.end(); ++it)
	{
		Instruction const instr{*it};
		int additional = 0;
		if (isValidInstruction(instr))
		{
			InstructionInfo const info = instructionInfo(instr, _evmVersion);
			additional = info.additional;
			if (info.maybeAdditional)
			{
				uint8_t imm = std::next(it) < _mem.end() ? *std::next(it) : 0;
				if (isValidMaybeAdditional(instr, imm, _evmVersion))
					additional += 1;
            }
		}
		int const totalAdditional = additional;

		u256 data{};

		// fill the data with the additional data bytes from the instruction stream
		while (additional > 0 && std::next(it) < _mem.end())
		{
			data <<= 8;
			data |= *++it;
			--additional;
		}

		// pad the remaining number of additional octets with zeros
		data <<= 8 * additional;

		_onInstruction(instr, data, totalAdditional);
	}
}

std::string solidity::evmasm::disassemble(bytes const& _mem, langutil::EVMVersion _evmVersion, std::string const& _delimiter)
{
	std::stringstream ret;
	eachInstruction(_mem, _evmVersion, [&](Instruction _instr, u256 const& _data, int _additional) {
		if (_evmVersion.hasDupSwapN() && (_instr == Instruction::DUPN || _instr == Instruction::SWAPN))
		{
			std::string const& name = instructionInfo(_instr, _evmVersion).name;
			if (_additional == 1)
				ret << name
					<< " "
					<< std::dec
					<< decodeDupSwapNImmediate(static_cast<uint8_t>(_data))
					<< _delimiter;
			else
				ret << "INVALID_" << name << _delimiter;
		}
		else if (!isValidInstruction(_instr))
			ret << "0x" << std::uppercase << std::hex << static_cast<int>(_instr) << _delimiter;
		else
		{
			InstructionInfo info = instructionInfo(_instr, _evmVersion);
			ret << info.name;
			if (info.additional)
				ret << " 0x" << std::uppercase << std::hex << _data;
			ret << _delimiter;
		}
	});
	return ret.str();
}
