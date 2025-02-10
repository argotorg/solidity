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
/** @file AssemblyItem.h
 * @author Gav Wood <i@gavwood.com>
 * @date 2014
 */

#pragma once

#include <libevmasm/Instruction.h>
#include <libevmasm/Exceptions.h>
#include <liblangutil/DebugData.h>
#include <liblangutil/Exceptions.h>
#include <libsolutil/Common.h>
#include <libsolutil/Numeric.h>
#include <libsolutil/Assertions.h>
#include <optional>
#include <iostream>
#include <sstream>

namespace solidity::evmasm
{

enum AssemblyItemType
{
	UndefinedItem,
	Operation,
	Push,
	PushTag,
	PushSub,
	PushSubSize,
	PushProgramSize,
	Tag,
	PushData,
	PushLibraryAddress, ///< Push a currently unknown address of another (library) contract.
	PushDeployTimeAddress, ///< Push an address to be filled at deploy time. Should not be touched by the optimizer.
	PushImmutable, ///< Push the currently unknown value of an immutable variable. The actual value will be filled in by the constructor.
	AssignImmutable, ///< Assigns the current value on the stack to an immutable variable. Only valid during creation code.

	/// Loads 32 bytes from static auxiliary data of EOF data section. The offset does *not* have to be always from the beginning
	/// of the data EOF section. More details here: https://github.com/ipsilon/eof/blob/main/spec/eof.md#data-section-lifecycle
	AuxDataLoadN,
	EOFCreate, ///< Creates new contract using subcontainer as initcode
	ReturnContract, ///< Returns new container (with auxiliary data filled in) to be deployed
	RelativeJump, ///< Jumps to relative position accordingly to its argument
	ConditionalRelativeJump, ///< Same as RelativeJump but takes condition from the stack
	CallF, ///< Jumps to a returning EOF function, adding a new frame to the return stack.
	JumpF, ///< Jumps to a returning or non-returning EOF function without changing the return stack.
	RetF, ///< Returns from an EOF function, removing a frame from the return stack.
	VerbatimBytecode, ///< Contains data that is inserted into the bytecode code section without modification.
	SwapN, ///< EOF SWAPN with immediate argument.
	DupN, ///< EOF DUPN with immediate argument.
};

enum class Precision { Precise , Approximate };

class Assembly;
class AssemblyItem;
using AssemblyItems = std::vector<AssemblyItem>;
using ContainerID = uint8_t;

class AssemblyItem
{
public:
	enum class JumpType { Ordinary, IntoFunction, OutOfFunction };

	AssemblyItem(u256 _push, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create()):
		AssemblyItem(Push, std::move(_push), std::move(_debugData)) { }
	AssemblyItem(Instruction _i, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create()):
		m_type(Operation),
		m_instruction(_i),
		m_debugData(std::move(_debugData))
	{}
	AssemblyItem(AssemblyItemType _type, u256 _data = 0, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create()):
		m_type(_type),
		m_debugData(std::move(_debugData))
	{
		if (m_type == Operation)
			m_instruction = Instruction(uint8_t(_data));
		else
			m_data = std::make_shared<u256>(std::move(_data));
	}

	explicit AssemblyItem(AssemblyItemType _type, Instruction _instruction, u256 _data = 0, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create()):
		m_type(_type),
		m_instruction(_instruction),
		m_data(std::make_shared<u256>(std::move(_data))),
		m_debugData(std::move(_debugData))
	{}

	explicit AssemblyItem(bytes _verbatimData, size_t _arguments, size_t _returnVariables):
		m_type(VerbatimBytecode),
		m_instruction{},
		m_verbatimBytecode{{_arguments, _returnVariables, std::move(_verbatimData)}},
		m_debugData{langutil::DebugData::create()}
	{}

	static AssemblyItem functionCall(uint16_t _functionID, uint8_t _args, uint8_t _rets, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		// TODO: Make this constructor this way that it's impossible to create it without setting functions signature.
		// It can be done by template constructor with Instruction as template parameter i.e. Same for JumpF below.
		AssemblyItem result(CallF, Instruction::CALLF, _functionID, _debugData);
		solAssert(_args <= 127 && _rets <= 127);
		result.m_functionSignature = {_args, _rets};
		return result;
	}
	static AssemblyItem jumpToFunction(uint16_t _functionID, uint8_t _args, uint8_t _rets, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		AssemblyItem result(JumpF, Instruction::JUMPF, _functionID, _debugData);
		solAssert(_args <= 127 && _rets <= 127);
		result.m_functionSignature = {_args, _rets};
		return result;
	}
	static AssemblyItem functionReturn(langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		return AssemblyItem(RetF, Instruction::RETF, 0, std::move(_debugData));
	}

	static AssemblyItem eofCreate(ContainerID _containerID, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		return AssemblyItem(EOFCreate, Instruction::EOFCREATE, _containerID, std::move(_debugData));
	}
	static AssemblyItem returnContract(ContainerID _containerID, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		return AssemblyItem(ReturnContract, Instruction::RETURNCONTRACT, _containerID, std::move(_debugData));
	}
	static AssemblyItem relativeJumpTo(AssemblyItem _tag, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		solAssert(_tag.type() == Tag);
		return AssemblyItem(RelativeJump, Instruction::RJUMP, _tag.data(), _debugData);
	}
	static AssemblyItem conditionalRelativeJumpTo(AssemblyItem _tag, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		solAssert(_tag.type() == Tag);
		return AssemblyItem(ConditionalRelativeJump, Instruction::RJUMPI, _tag.data(), _debugData);
	}
	static AssemblyItem swapN(size_t _depth, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		solAssert(_depth >= 1 && _depth <= 256);
		return AssemblyItem(SwapN, Instruction::SWAPN, _depth, _debugData);
	}
	static AssemblyItem dupN(size_t _depth, langutil::DebugData::ConstPtr _debugData = langutil::DebugData::create())
	{
		solAssert(_depth >= 1 && _depth <= 256);
		return AssemblyItem(DupN, Instruction::DUPN, _depth, _debugData);
	}

	AssemblyItem(AssemblyItem const&) = default;
	AssemblyItem(AssemblyItem&&) = default;
	AssemblyItem& operator=(AssemblyItem const&) = default;
	AssemblyItem& operator=(AssemblyItem&&) = default;

	AssemblyItem tag() const { solAssert(m_type == PushTag || m_type == Tag || m_type == RelativeJump || m_type == ConditionalRelativeJump); return AssemblyItem(Tag, data()); }
	AssemblyItem pushTag() const { solAssert(m_type == PushTag || m_type == Tag || m_type == RelativeJump || m_type == ConditionalRelativeJump); return AssemblyItem(PushTag, data()); }
	/// Converts the tag to a subassembly tag. This has to be called in order to move a tag across assemblies.
	/// @param _subId the identifier of the subassembly the tag is taken from.
	AssemblyItem toSubAssemblyTag(size_t _subId) const;
	/// @returns splits the data of the push tag into sub assembly id and actual tag id.
	/// The sub assembly id of non-foreign push tags is -1.
	std::pair<size_t, size_t> splitForeignPushTag() const;
	/// @returns relative jump target tag ID. Asserts that it is not foreign tag.
	size_t relativeJumpTagID() const;
	/// Sets sub-assembly part and tag for a push tag.
	void setPushTagSubIdAndTag(size_t _subId, size_t _tag);

	AssemblyItemType type() const { return m_type; }
	u256 const& data() const { solAssert(m_type != Operation && m_data != nullptr); return *m_data; }
	void setData(u256 const& _data) { assertThrow(m_type != Operation, util::Exception, ""); m_data = std::make_shared<u256>(_data); }

	/// This function is used in `Assembly::assemblyJSON`.
	/// It returns the name & data of the current assembly item.
	/// @param _evmVersion the EVM version.
	/// @returns a pair, where the first element is the json-assembly
	/// item name, where second element is the string representation
	/// of it's data.
	std::pair<std::string, std::string> nameAndData(langutil::EVMVersion _evmVersion) const;

	bytes const& verbatimData() const { assertThrow(m_type == VerbatimBytecode, util::Exception, ""); return std::get<2>(*m_verbatimBytecode); }

	/// @returns true if the item has m_instruction properly set.
	bool hasInstruction() const
	{
		return
			m_type == Operation ||
			m_type == EOFCreate ||
			m_type == ReturnContract ||
			m_type == RelativeJump ||
			m_type == ConditionalRelativeJump ||
			m_type == CallF ||
			m_type == JumpF ||
			m_type == RetF ||
			m_type == SwapN ||
			m_type == DupN;
	}
	/// @returns the instruction of this item (only valid if hasInstruction returns true)
	Instruction instruction() const
	{
		solAssert(hasInstruction());
		return m_instruction;
	}

	/// @returns true if the type and data of the items are equal.
	bool operator==(AssemblyItem const& _other) const
	{
		if (type() != _other.type())
			return false;
		if (type() == Operation)
			return instruction() == _other.instruction();
		else if (type() == VerbatimBytecode)
			return *m_verbatimBytecode == *_other.m_verbatimBytecode;
		else
			return data() == _other.data();
	}
	bool operator!=(AssemblyItem const& _other) const { return !operator==(_other); }
	/// Less-than operator compatible with operator==.
	bool operator<(AssemblyItem const& _other) const
	{
		if (type() != _other.type())
			return type() < _other.type();
		else if (type() == Operation)
			return instruction() < _other.instruction();
		else if (type() == VerbatimBytecode)
			return *m_verbatimBytecode < *_other.m_verbatimBytecode;
		else
			return data() < _other.data();
	}

	/// Shortcut that avoids constructing an AssemblyItem just to perform the comparison.
	bool operator==(Instruction _instr) const
	{
		return type() == Operation && instruction() == _instr;
	}
	bool operator!=(Instruction _instr) const { return !operator==(_instr); }

	static std::string computeSourceMapping(
		AssemblyItems const& _items,
		std::map<std::string, unsigned> const& _sourceIndicesMap
	);

	/// @returns an upper bound for the number of bytes required by this item, assuming that
	/// the value of a jump tag takes @a _addressLength bytes.
	/// @param _evmVersion the EVM version
	/// @param _precision Whether to return a precise count (which involves
	///                   counting immutable references which are only set after
	///                   a call to `assemble()`) or an approx. count.
	size_t bytesRequired(size_t _addressLength, langutil::EVMVersion _evmVersion, Precision _precision = Precision::Precise) const;
	size_t arguments() const;
	size_t returnValues() const;
	size_t deposit() const { return returnValues() - arguments(); }

	/// @returns true if the assembly item can be used in a functional context.
	bool canBeFunctional() const;

	void setLocation(langutil::SourceLocation const& _location)
	{
		solAssert(m_debugData);
		m_debugData = langutil::DebugData::create(
			_location,
			m_debugData->originLocation,
			m_debugData->astID
		);
	}

	langutil::SourceLocation const& location() const
	{
		solAssert(m_debugData);
		return m_debugData->nativeLocation;
	}

	void setDebugData(langutil::DebugData::ConstPtr _debugData)
	{
		solAssert(_debugData);
		m_debugData = std::move(_debugData);
	}

	langutil::DebugData::ConstPtr debugData() const { return m_debugData; }

	void setJumpType(JumpType _jumpType) { m_jumpType = _jumpType; }
	static std::optional<JumpType> parseJumpType(std::string const& _jumpType);
	JumpType getJumpType() const { return m_jumpType; }
	std::string getJumpTypeAsString() const;

	void setPushedValue(u256 const& _value) const { m_pushedValue = std::make_shared<u256>(_value); }
	u256 const* pushedValue() const { return m_pushedValue.get(); }

	std::string toAssemblyText(Assembly const& _assembly) const;

	size_t m_modifierDepth = 0;

	void setImmutableOccurrences(size_t _n) const { m_immutableOccurrences = _n; }

	struct FunctionSignature
	{
		/// Number of EOF function arguments. must be less than 128
		uint8_t argsNum;
		/// Number of EOF function return values. Must be less than 128.
		uint8_t retsNum;
	};

	FunctionSignature const& functionSignature() const
	{
		solAssert(m_type == CallF || m_type == JumpF);
		solAssert(m_functionSignature.has_value());
		return *m_functionSignature;
	}

private:
	size_t opcodeCount() const noexcept;

	AssemblyItemType m_type;
	Instruction m_instruction; ///< Only valid if m_type == Operation
	std::shared_ptr<u256> m_data; ///< Only valid if m_type != Operation
	std::optional<FunctionSignature> m_functionSignature; ///< Only valid if m_type == CallF or JumpF
	/// If m_type == VerbatimBytecode, this holds number of arguments, number of
	/// return variables and verbatim bytecode.
	std::optional<std::tuple<size_t, size_t, bytes>> m_verbatimBytecode;
	langutil::DebugData::ConstPtr m_debugData;
	JumpType m_jumpType = JumpType::Ordinary;
	/// Pushed value for operations with data to be determined during assembly stage,
	/// e.g. PushSubSize, PushTag, PushSub, etc.
	mutable std::shared_ptr<u256> m_pushedValue;
	/// Number of PushImmutable's with the same hash. Only used for AssignImmutable.
	mutable std::optional<size_t> m_immutableOccurrences;
};

inline size_t bytesRequired(AssemblyItems const& _items, size_t _addressLength, langutil::EVMVersion _evmVersion, Precision _precision = Precision::Precise)
{
	size_t size = 0;
	for (AssemblyItem const& item: _items)
		size += item.bytesRequired(_addressLength, _evmVersion, _precision);
	return size;
}

std::ostream& operator<<(std::ostream& _out, AssemblyItem const& _item);
inline std::ostream& operator<<(std::ostream& _out, AssemblyItems const& _items)
{
	for (AssemblyItem const& item: _items)
		_out << item;
	return _out;
}

}
