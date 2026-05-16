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
/** @file ConstantOptimiser.cpp
 * @author Christian <c@ethdev.com>
 * @date 2015
 */

#include <libevmasm/ConstantOptimiser.h>
#include <libevmasm/Assembly.h>
#include <libevmasm/GasMeter.h>

using namespace solidity;
using namespace solidity::evmasm;

unsigned ConstantOptimisationMethod::optimiseConstants(
	bool _isCreation,
	std::uint64_t _runs,
	langutil::EVMVersion _evmVersion,
	Assembly& _assembly
)
{
	// TODO: design the optimiser in a way this is not needed
	unsigned optimisations = 0;
	AssemblyItems& items = _assembly.items();

	std::map<AssemblyItem, size_t> pushes;
	for (AssemblyItem const& item: items)
		if (item.type() == Push)
			pushes[item]++;
	std::map<u256, AssemblyItems> pendingReplacements;
	for (auto it: pushes)
	{
		AssemblyItem const& item = it.first;
		if (item.data() < 0x100)
			continue;
		Params params;
		params.multiplicity = it.second;
		params.isCreation = _isCreation;
		params.runs = _runs;
		params.evmVersion = _evmVersion;
		LiteralMethod lit(params, item.data());
		bigint literalGas = lit.gasNeeded();
		CodeCopyMethod copy(params, item.data());
		bigint copyGas = copy.gasNeeded();
		ComputeMethod compute(params, item.data());
		bigint computeGas = compute.gasNeeded();
		AssemblyItems replacement;
		if (copyGas < literalGas && copyGas < computeGas)
		{
			replacement = copy.execute(_assembly);
			optimisations++;
		}
		else if (computeGas < literalGas && computeGas <= copyGas)
		{
			replacement = compute.execute(_assembly);
			optimisations++;
		}
		if (!replacement.empty())
			pendingReplacements[item.data()] = replacement;
	}
	if (!pendingReplacements.empty())
		replaceConstants(items, pendingReplacements);

	return optimisations;
}

bigint ConstantOptimisationMethod::simpleRunGas(AssemblyItems const& _items, langutil::EVMVersion _evmVersion)
{
	bigint gas = 0;
	for (AssemblyItem const& item: _items)
		if (item.type() == Push)
			gas += GasMeter::pushGas(item.data(), _evmVersion);
		else if (item.type() == Operation)
		{
			assertThrow(item.instruction() != Instruction::EXP, OptimizerException, "EXP used in constant optimizer.");
			gas += GasMeter::runGas(item.instruction(), _evmVersion);
		}
	return gas;
}

bigint ConstantOptimisationMethod::dataGas(bytes const& _data) const
{
	assertThrow(_data.size() > 0, OptimizerException, "Empty bytecode generated.");
	return bigint(GasMeter::dataGas(_data, m_params.isCreation, m_params.evmVersion));
}

size_t ConstantOptimisationMethod::bytesRequired(AssemblyItems const& _items, langutil::EVMVersion _evmVersion)
{
	return evmasm::bytesRequired(_items, 3, _evmVersion, Precision::Approximate); // assume 3 byte addresses
}

void ConstantOptimisationMethod::replaceConstants(
	AssemblyItems& _items,
	std::map<u256, AssemblyItems> const& _replacements
)
{
	AssemblyItems replaced;
	for (AssemblyItem const& item: _items)
	{
		if (item.type() == Push)
		{
			auto it = _replacements.find(item.data());
			if (it != _replacements.end())
			{
				replaced += it->second;
				continue;
			}
		}
		replaced.push_back(item);
	}
	_items = std::move(replaced);
}

bigint LiteralMethod::gasNeeded() const
{
	return combineGas(
		simpleRunGas({Instruction::PUSH1}, m_params.evmVersion),
		// PUSHX plus data
		(m_params.isCreation ? GasCosts::txDataNonZeroGas(m_params.evmVersion) : GasCosts::createDataGas) + dataGas(toCompactBigEndian(m_value, 1)),
		0
	);
}

AssemblyItems LiteralMethod::execute(Assembly&) const
{
	return {};
}

bigint CodeCopyMethod::gasNeeded() const
{
	return combineGas(
		// Run gas: we ignore memory increase costs
		simpleRunGas(copyRoutine(), m_params.evmVersion) + GasCosts::copyGas,
		// Data gas for copy routines: Some bytes are zero, but we ignore them.
		bytesRequired(copyRoutine(), m_params.evmVersion) * (m_params.isCreation ? GasCosts::txDataNonZeroGas(m_params.evmVersion) : GasCosts::createDataGas),
		// Data gas for data itself
		dataGas(toBigEndian(m_value))
	);
}

AssemblyItems CodeCopyMethod::execute(Assembly& _assembly) const
{
	bytes data = toBigEndian(m_value);
	assertThrow(data.size() == 32, OptimizerException, "Invalid number encoding.");
	AssemblyItem newPushData = _assembly.newData(data);
	return copyRoutine(&newPushData);
}

AssemblyItems CodeCopyMethod::copyRoutine(AssemblyItem* _pushData) const
{
	if (_pushData)
		assertThrow(_pushData->type() == PushData, OptimizerException, "Invalid Assembly Item.");

	AssemblyItem dataUsed = _pushData ? *_pushData : AssemblyItem(PushData, u256(1) << 16);

	// PUSH0 is cheaper than PUSHn/DUP/SWAP.
	if (m_params.evmVersion.hasPush0())
	{
		// This costs ~29 gas.
		AssemblyItems copyRoutine{
			// back up memory
			// mload(0)
			u256(0),
			Instruction::MLOAD,

			// codecopy(0, <offset>, 32)
			u256(32),
			dataUsed,
			u256(0),
			Instruction::CODECOPY,

			// mload(0)
			u256(0),
			Instruction::MLOAD,

			// restore original memory
			// mstore(0, x)
			Instruction::SWAP1,
			u256(0),
			Instruction::MSTORE
		};
		return copyRoutine;
	}
	else
	{
		// This costs ~33 gas.
		AssemblyItems copyRoutine{
			// constant to be reused 3+ times
			u256(0),

			// back up memory
			// mload(0)
			Instruction::DUP1,
			Instruction::MLOAD,

			// codecopy(0, <offset>, 32)
			u256(32),
			dataUsed,
			Instruction::DUP4,
			Instruction::CODECOPY,

			// mload(0)
			Instruction::DUP2,
			Instruction::MLOAD,

			// restore original memory
			// mstore(0, x)
			Instruction::SWAP2,
			Instruction::MSTORE
		};
		return copyRoutine;
	}
}

ComputeMethod::ComputeMethod(Params const& _params, u256 const& _value):
	ConstantOptimisationMethod(_params, _value)
{
	m_routine = findRepresentation(m_value);
	assertThrow(
		checkRepresentation(m_value, m_routine),
		OptimizerException,
		"Invalid constant expression created."
	);
}
ComputeMethod::~ComputeMethod() = default;

AssemblyItems ComputeMethod::execute(Assembly&) const
{
	return m_routine;
}

AssemblyItems ComputeMethod::tryNegation(u256 const& _value, AssemblyItems const& _bestSoFar)
{
	if (numberEncodingSize(~_value) < numberEncodingSize(_value))
	{
		AssemblyItems newRoutine = findRepresentationRecursive(~_value, 256) + AssemblyItems{Instruction::NOT};
		if (gasNeeded(newRoutine) < gasNeeded(_bestSoFar))
			return newRoutine;
	}
	return _bestSoFar;
}

// finds patterns like 000....001111 (a bunch of 1's in the least significant part)
AssemblyItems ComputeMethod::tryNotZeroShiftRight(u256 const& _value, AssemblyItems const& _bestSoFar)
{
	unsigned onesAtEnd = 0;
	while (((_value >> onesAtEnd) & 1) == 1 && onesAtEnd < 256)
		++onesAtEnd;

	if ((_value >> onesAtEnd) == 0) // implicitly checks that onesAtEnd > 0
	{
		AssemblyItems newRoutine = AssemblyItems{u256(0), Instruction::NOT};
		newRoutine += AssemblyItems{u256(256 - onesAtEnd), Instruction::SHR};
		if (gasNeeded(newRoutine) < gasNeeded(_bestSoFar))
			return newRoutine;
	}
	return _bestSoFar;
}

// finds patterns like 1111.....00000 (a bunch of 1's in the most significant part)
AssemblyItems ComputeMethod::tryNotZeroShiftLeft(u256 const& _value, AssemblyItems const& _bestSoFar)
{
	unsigned onesAtStart = 0;
	while (onesAtStart < 256 && ((_value >> (255 - onesAtStart)) & 1) == 1)
		++onesAtStart;

	if ((_value << onesAtStart) == 0) // implicitly checks that onesAtStart > 0
	{
		AssemblyItems newRoutine = AssemblyItems{u256(0), Instruction::NOT};
		newRoutine += AssemblyItems{u256(256 - onesAtStart), Instruction::SHL};
		if (gasNeeded(newRoutine) < gasNeeded(_bestSoFar))
			return newRoutine;
	}
	return _bestSoFar;
}

// finds patterns like xxxx00000 (a bunch of 0's in the least significant part)
AssemblyItems ComputeMethod::tryLeftShift(u256 const& _value, AssemblyItems const& _bestSoFar, unsigned targetBits)
{
	unsigned zerosAtEnd = 0;
	while (((_value >> zerosAtEnd) & 1) == 0 && zerosAtEnd < 256)
		++zerosAtEnd;

	if (zerosAtEnd >= 16)
	{
		AssemblyItems newRoutine = findRepresentationRecursive(_value >> zerosAtEnd, targetBits - zerosAtEnd);
		newRoutine += AssemblyItems{u256(zerosAtEnd), Instruction::SHL};
		if (gasNeeded(newRoutine) < gasNeeded(_bestSoFar))
			return newRoutine;
	}
	return _bestSoFar;
}

// decomposes the constant into a | b at byte boundaries, works well when either side can be represented easily
// example: 0x2300000000000017
// note: addition doesn't work better than OR and is conceptually more difficult (overflow, carry, etc)
// large example with OR:
// value = fffffffffffffffffffffffdffffffff0000000000000000ffffffffffffffff
// repr =  PUSH 1 PUSH 61 SHL PUSH 0 NOT PUSH c0 SHR OR PUSH 40 SHL NOT
AssemblyItems ComputeMethod::tryAorB(u256 const& _value, AssemblyItems const& _bestSoFar, unsigned targetBits)
{
	// don't recurse too much
	if (m_recursionDepth >= 2)
		return _bestSoFar;
	m_recursionDepth++;
	AssemblyItems routine = _bestSoFar;
	bigint bestGas = gasNeeded(routine);
	bigint upperBareMinGas = gasNeeded(AssemblyItems{u256(1)} + AssemblyItems{u256(2)} + AssemblyItems{Instruction::SHL});
	for (unsigned bits = 8; bits < targetBits; bits += 8)
	{
		u256 powerOfTwo = u256(1) << bits;
		u256 upperPart = (_value >> bits) << bits;
		if (upperPart == 0)
			break;
		u256 lowerPart = _value & (powerOfTwo - 1);
		if (lowerPart != 0)
		{
			AssemblyItems lowerRep = findRepresentationRecursive(lowerPart, bits);
			// try an early exit with a mock upper part -- makes a huge speed difference
			if (gasNeeded(lowerRep) + upperBareMinGas >= gasNeeded(routine)) // it'll never get better, because lower gets more and more complex
				break;
			AssemblyItems newRoutine = findRepresentationRecursive(upperPart, targetBits) + lowerRep + AssemblyItems{Instruction::OR};
			bigint newGas = gasNeeded(newRoutine);
			if (newGas < bestGas)
			{
				routine = newRoutine;
				bestGas = newGas;
			}
		}
	}
	m_recursionDepth--;
	return routine;
}

// subtraction can cause a lot of bit flips
// bits that are set cost more to represent, so setting them cheaply is the goal here
// looks for byte wise subtractions that cause a bit flip in the next byte.
// 0x12FFFF76 => what do we need to add to 0x76 to flip the next highest bit? 0x100 - 0x76 = 0x8A
// 0x12FFFF76 = 0x13000000 - 0x8A
// note: addition doesn't work much better than OR, which is tried above
// very few real-world bit patterns are optimal with SUB
// large example:
// value = 3fffffffffffffffc0 repr =  PUSH 40 PUSH 1 PUSH 46 SHL SUB
// just beats out PUSH0 NOT PUSH R SHR PUSH L SHL -- same number of bytes, more gas with ~0
AssemblyItems ComputeMethod::trySub(u256 const& _value, AssemblyItems const& _bestSoFar, unsigned targetBits)
{
	// don't recurse too much
	if (m_recursionDepth >= 2)
		return _bestSoFar;
	m_recursionDepth++;
	AssemblyItems routine = _bestSoFar;
	u256 lastRhs = 0;
	for (unsigned bits = 8; bits < 32; bits += 8) //higher bits don't seem to help
	{
		u256 powerOfTwo = u256(1) << bits;
		u256 lowerPart = _value & (powerOfTwo - 1);
		if (lowerPart != 0)
		{
			u256 rhs = powerOfTwo - lowerPart;
			if (rhs > _value)
				break;
			if (lastRhs != rhs) { // don't try the same routine again
				u256 lhs = _value + rhs; // we want _value = lhs - rhs
				lastRhs = rhs;
				AssemblyItems newRoutine = findRepresentationRecursive(rhs, bits) + findRepresentationRecursive(lhs, targetBits + 1) + AssemblyItems{Instruction::SUB};
				if (gasNeeded(newRoutine) < gasNeeded(routine))
					routine = newRoutine;
			}
		}
	}
	m_recursionDepth--;
	return routine;
}

AssemblyItems ComputeMethod::findRepresentation(u256 const& _value)
{
	AssemblyItems routine = AssemblyItems{_value};
	if (_value < 0x100000000)
		// Very small value, always optimal as is; empirically, even at optimize-runs 1, no computation is better
		// 0x100000000 is the first small number that has a "better" representation than PUSH5: PUSH1 0x1 PUSH1 0x20 SHL
		// "better" only for low runs
		return routine;

	return findRepresentationRecursive(_value, 256);
}

AssemblyItems ComputeMethod::findRepresentationRecursive(u256 const& _value, unsigned targetBits)
{
	AssemblyItems routine = AssemblyItems{_value};
	if (_value < 0x100000000)
		// Very small value, always optimal as is; empirically, even at optimize-runs 1, no computation is better
		// 0x100000000 is the first small number that has a "better" representation than PUSH5: PUSH1 0x1 PUSH1 0x20 SHL
		// "better" only for low runs
		return routine;

	// filter out numbers with random bit patterns. we want at least 32 contiguous zeros or ones
	u256 mask32bit = (u256(1) << 32) - 1;
	bool found = _value < (u256(1) << (targetBits - 32)); // if upper bits are zero, it'll pass the loop test
	for(unsigned i = 0; i < (targetBits - 32) && !found; i++)
	{
		u256 chunk = (_value >> i) & mask32bit;
		found = chunk == 0 || chunk == mask32bit;
	}
	if (!found)
		return routine;

	if (targetBits >= 256)
		routine = tryNegation(_value, std::move(routine));

	if (m_params.evmVersion.hasBitwiseShifting())
	{
		routine = tryLeftShift(_value, routine, targetBits);
		routine = tryNotZeroShiftRight(_value, routine);
		if (targetBits >= 256)
			routine = tryNotZeroShiftLeft(_value, std::move(routine));
	}
	routine = tryAorB(_value, routine, targetBits);
	routine = trySub(_value, routine, targetBits);
	return routine;
}

bool ComputeMethod::checkRepresentation(u256 const& _value, AssemblyItems const& _routine) const
{
	// This is a tiny EVM that can only evaluate some instructions.
	std::vector<u256> stack;
	for (AssemblyItem const& item: _routine)
	{
		switch (item.type())
		{
		case Operation:
		{
			if (stack.size() < item.arguments())
				return false;
			u256* sp = &stack.back();
			switch (item.instruction())
			{
			case Instruction::MUL:
				sp[-1] = sp[0] * sp[-1];
				break;
			case Instruction::EXP:
				if (sp[-1] > 0xff)
					return false;
				sp[-1] = boost::multiprecision::pow(sp[0], unsigned(sp[-1]));
				break;
			case Instruction::ADD:
				sp[-1] = sp[0] + sp[-1];
				break;
			case Instruction::SUB:
				sp[-1] = sp[0] - sp[-1];
				break;
			case Instruction::OR:
				sp[-1] = sp[0] | sp[-1];
				break;
			case Instruction::NOT:
				sp[0] = ~sp[0];
				break;
			case Instruction::SHL:
				assertThrow(
					m_params.evmVersion.hasBitwiseShifting(),
					OptimizerException,
					"Shift generated for invalid EVM version."
				);
				assertThrow(sp[0] <= u256(255), OptimizerException, "Invalid shift generated.");
				sp[-1] = u256(bigint(sp[-1]) << unsigned(sp[0]));
				break;
			case Instruction::SHR:
				assertThrow(
					m_params.evmVersion.hasBitwiseShifting(),
					OptimizerException,
					"Shift generated for invalid EVM version."
				);
				assertThrow(sp[0] <= u256(255), OptimizerException, "Invalid shift generated.");
				sp[-1] = sp[-1] >> unsigned(sp[0]);
				break;
			default:
				return false;
			}
			stack.resize(stack.size() + item.deposit());
			break;
		}
		case Push:
			stack.push_back(item.data());
			break;
		default:
			return false;
		}
	}
	return stack.size() == 1 && stack.front() == _value;
}

bigint ComputeMethod::gasNeeded(AssemblyItems const& _routine) const
{
	return combineGas(
		simpleRunGas(_routine, m_params.evmVersion),
		// Data gas for routine: Some bytes are zero, but we ignore them.
		bytesRequired(_routine, m_params.evmVersion) * (m_params.isCreation ? GasCosts::txDataNonZeroGas(m_params.evmVersion) : GasCosts::createDataGas),
		0
	);
}
