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
 * Control flow graph and stack layout structures used during code generation.
 */

#pragma once

#include <libyul/backends/evm/ssa/SSACFGDebugInfo.h>
#include <libyul/backends/evm/ssa/SSACFGTypes.h>

#include <libyul/AST.h>
#include <libyul/AsmAnalysisInfo.h>
#include <libyul/Dialect.h>
#include <libyul/Exceptions.h>
#include <libyul/Scope.h>

#include <libsolutil/Numeric.h>

#include <range/v3/view/map.hpp>
#include <deque>
#include <functional>
#include <list>
#include <vector>

namespace solidity::yul::ssa
{
class LivenessAnalysis;

class SSACFG
{
public:
	using DebugInfo = SSACFGDebugInfo;

	explicit SSACFG(std::unique_ptr<DebugInfo> _debugInfo = std::make_unique<DebugInfo>()):
		debugInfo(std::move(_debugInfo))
	{}

	SSACFG(SSACFG const&) = delete;
	SSACFG(SSACFG&&) = delete;
	SSACFG& operator=(SSACFG const&) = delete;
	SSACFG& operator=(SSACFG&&) = delete;
	~SSACFG() = default;

	using BlockId = ssa::BlockId;
	using OperationId = ssa::OperationId;
	using ValueId = ssa::ValueId;

	struct BuiltinCall
	{
		std::reference_wrapper<BuiltinFunction const> builtin;
		std::reference_wrapper<FunctionCall const> call;
	};
	struct Call
	{
		std::reference_wrapper<Scope::Function const> function;
		std::reference_wrapper<FunctionCall const> call;
		bool canContinue;
	};
	struct LiteralAssignment {};

	/// Upsilon records a phi pre-image at a block exit.
	/// Upsilon(value, phi) means: the value flowing into `phi` from this block is `value`.
	/// Lives in the predecessor block; the corresponding Phi lives in the successor.
	struct Upsilon
	{
		ValueId value;  ///< pre-image value for the phi
		ValueId phi;    ///< target phi
	};

	struct Operation {
		std::vector<ValueId> outputs{};
		std::variant<BuiltinCall, Call, LiteralAssignment> kind;
		std::vector<ValueId> inputs{};
	};
	struct BasicBlock
	{
		struct MainExit {};
		struct ConditionalJump
		{
			ValueId condition;
			BlockId nonZero;
			BlockId zero;
		};
		struct Jump
		{
			BlockId target;
		};
		struct FunctionReturn
		{
			std::vector<ValueId> returnValues;
		};
		struct Terminated {};
		std::vector<BlockId> entries;
		std::vector<ValueId> phis;
		std::vector<OperationId> operations;
		/// Upsilon assignments placed at the block exit (before the terminator).
		/// They record the phi pre-images for successor blocks.
		std::vector<Upsilon> upsilons;
		std::variant<MainExit, Jump, ConditionalJump, FunctionReturn, Terminated> exit = MainExit{};
		template<typename Callable>
		void forEachExit(Callable&& _callable) const
		{
			if (auto* jump = std::get_if<Jump>(&exit))
				_callable(jump->target);
			else if (auto* conditionalJump = std::get_if<ConditionalJump>(&exit))
			{
				_callable(conditionalJump->nonZero);
				_callable(conditionalJump->zero);
			}
		}

		bool isMainExitBlock() const
		{
			return std::holds_alternative<MainExit>(exit);
		}

		bool isTerminationBlock() const
		{
			return std::holds_alternative<Terminated>(exit);
		}

		bool isFunctionReturnBlock() const
		{
			return std::holds_alternative<FunctionReturn>(exit);
		}

		bool isJumpBlock() const
		{
			return std::holds_alternative<Jump>(exit);
		}
	};

	BlockId makeBlock(langutil::DebugData::ConstPtr _debugData)
	{
		BlockId blockId { static_cast<BlockId::ValueType>(m_blocks.size()) };
		m_blocks.emplace_back(BasicBlock{{}, {}, {}, {}, BasicBlock::Terminated{}});
		if (debugInfo)
			debugInfo->setBlockDebugData(blockId, std::move(_debugData));
		return blockId;
	}
	BasicBlock& block(BlockId _id) { return m_blocks.at(_id.value); }
	BasicBlock const& block(BlockId _id) const { return m_blocks.at(_id.value); }
	size_t numBlocks() const { return m_blocks.size(); }

	OperationId makeOperation(Operation _op, langutil::DebugData::ConstPtr _debugData = {})
	{
		OperationId id{static_cast<OperationId::ValueType>(m_operations.size())};
		m_operations.emplace_back(std::move(_op));
		if (debugInfo && _debugData)
			debugInfo->setOperationDebugData(id, std::move(_debugData));
		return id;
	}
	Operation& operation(OperationId _id) { return m_operations.at(_id.value); }
	Operation const& operation(OperationId _id) const { return m_operations.at(_id.value); }

private:
	std::vector<BasicBlock> m_blocks;
	std::vector<Operation> m_operations;
public:
	struct LiteralValue {
		u256 value;
	};
	struct VariableValue {
		BlockId definingBlock;
	};
	struct PhiValue {
		BlockId block;
	};
	struct UnreachableValue {};
	ValueId newPhi(BlockId const _definingBlock)
	{
		m_phis.emplace_back(PhiValue{_definingBlock});
		auto const value = m_phis.size() - 1;
		yulAssert(value < std::numeric_limits<ValueId::ValueType>::max());
		auto const id = ValueId::makePhi(static_cast<ValueId::ValueType>(value));
		if (debugInfo)
			debugInfo->setValueDebugData(id, debugInfo->blockDebugData(_definingBlock));
		return id;
	}
	ValueId newVariable(BlockId const _definingBlock)
	{
		m_variables.emplace_back(VariableValue{_definingBlock});
		auto const value = m_variables.size() - 1;
		yulAssert(value < std::numeric_limits<ValueId::ValueType>::max());
		auto const id = ValueId::makeVariable(static_cast<ValueId::ValueType>(value));
		if (debugInfo)
			debugInfo->setValueDebugData(id, debugInfo->blockDebugData(_definingBlock));
		return id;
	}

	ValueId unreachableValue()
	{
		if (!m_unreachableValue)
			m_unreachableValue = ValueId::makeUnreachable();
		return *m_unreachableValue;
	}

	ValueId newLiteral(langutil::DebugData::ConstPtr _debugData, u256 _value)
	{
		auto const it = m_literalMapping.find(_value);
		if (it != m_literalMapping.end())
		{
			ValueId const& valueId = it->second;
			yulAssert(valueId.hasValue() && m_literals[valueId.value()].value == _value);
			return valueId;
		}

		m_literals.emplace_back(LiteralValue{std::move(_value)});
		auto const value = m_literals.size() - 1;
		yulAssert(value < std::numeric_limits<ValueId::ValueType>::max());
		auto const literalId = ValueId::makeLiteral(static_cast<ValueId::ValueType>(value));
		if (debugInfo)
			debugInfo->setValueDebugData(literalId, std::move(_debugData));
		m_literalMapping.emplace(_value, literalId);
		return literalId;
	}

	std::string toDot(
		bool _includeDiGraphDefinition=true,
		std::optional<size_t> _functionIndex=std::nullopt,
		LivenessAnalysis const* _liveness=nullptr
	) const;

	PhiValue const& phiInfo(ValueId const& _valueId) const
	{
		yulAssert(_valueId.hasValue() && _valueId.isPhi());
		return m_phis.at(_valueId.value());
	}
	PhiValue& phiInfo(ValueId const& _valueId)
	{
		yulAssert(_valueId.hasValue() && _valueId.isPhi());
		return m_phis.at(_valueId.value());
	}
	LiteralValue const& literalInfo(ValueId const& _valueId) const
	{
		yulAssert(_valueId.hasValue() && _valueId.isLiteral());
		return m_literals.at(_valueId.value());
	}
	VariableValue const& variableInfo(ValueId const& _valueId) const
	{
		yulAssert(_valueId.hasValue() && _valueId.isVariable());
		return m_variables.at(_valueId.value());
	}

private:
	std::vector<LiteralValue> m_literals;
	std::map<u256, ValueId> m_literalMapping;
	std::vector<PhiValue> m_phis;
	std::vector<VariableValue> m_variables;
	std::optional<ValueId> m_unreachableValue;
public:
	std::unique_ptr<DebugInfo> debugInfo;
	BlockId entry = BlockId{0};
	std::set<BlockId> exits;
	Scope::Function const* function = nullptr;
	bool canContinue = true;
	std::vector<std::tuple<std::reference_wrapper<Scope::Variable const>, ValueId>> arguments;
	std::vector<std::reference_wrapper<Scope::Variable const>> returns;
	std::vector<std::reference_wrapper<Scope::Function const>> functions;
	// Container for artificial calls generated for switch statements.
	std::list<FunctionCall> ghostCalls;
};

}
