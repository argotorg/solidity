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
	SSACFG() = default;
	SSACFG(SSACFG const&) = delete;
	SSACFG(SSACFG&&) = delete;
	SSACFG& operator=(SSACFG const&) = delete;
	SSACFG& operator=(SSACFG&&) = delete;
	~SSACFG() = default;

	struct BlockId
	{
		using ValueType = std::uint32_t;
		ValueType value = std::numeric_limits<ValueType>::max();
		bool hasValue() const { return value != std::numeric_limits<ValueType>::max(); }
		auto operator<=>(BlockId const&) const = default;
	};
	class ValueId
	{
	public:
		enum class Kind: std::uint8_t
		{
			Literal,
			Variable,
			Phi,
			Unreachable
		};
		using ValueType = std::uint32_t;

		constexpr ValueId() = default;
		constexpr ValueId(ValueType const _value, Kind const _kind): m_value(_value), m_kind(_kind) {}
		constexpr ValueId(ValueId const&) = default;
		constexpr ValueId(ValueId&&) = default;
		constexpr ValueId& operator=(ValueId const&) = default;
		constexpr ValueId& operator=(ValueId&&) = default;

		static ValueId constexpr makeLiteral(ValueType const& _value) { return ValueId{_value, Kind::Literal}; }
		static ValueId constexpr makeVariable(ValueType const& _value) { return ValueId{_value, Kind::Variable}; }
		static ValueId constexpr makePhi(ValueType const& _value) { return ValueId{_value, Kind::Phi}; }
		static ValueId constexpr makeUnreachable() { return ValueId{0u, Kind::Unreachable}; }

		bool constexpr isLiteral() const noexcept { return m_kind == Kind::Literal; }
		bool constexpr isVariable() const noexcept { return m_kind == Kind::Variable; }
		bool constexpr isPhi() const noexcept { return m_kind == Kind::Phi; }
		bool constexpr isUnreachable() const noexcept { return m_kind == Kind::Unreachable; }

		bool constexpr hasValue() const { return m_value != std::numeric_limits<ValueType>::max(); }
		ValueType constexpr value() const noexcept { return m_value; }
		Kind constexpr kind() const noexcept { return m_kind; }
		std::string str(SSACFG const& _cfg) const;

		auto operator<=>(ValueId const&) const = default;

	private:
		ValueType m_value{std::numeric_limits<ValueType>::max()};
		Kind m_kind{Kind::Unreachable};
	};

	struct BuiltinCall
	{
		langutil::DebugData::ConstPtr debugData;
		std::reference_wrapper<BuiltinFunction const> builtin;
		std::reference_wrapper<FunctionCall const> call;
	};
	struct Call
	{
		langutil::DebugData::ConstPtr debugData;
		std::reference_wrapper<Scope::Function const> function;
		std::reference_wrapper<FunctionCall const> call;
		bool canContinue;
	};
	struct LiteralAssignment
	{
		langutil::DebugData::ConstPtr debugData;
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
			langutil::DebugData::ConstPtr debugData{};
			ValueId condition;
			BlockId nonZero;
			BlockId zero;
		};
		struct Jump
		{
			langutil::DebugData::ConstPtr debugData{};
			BlockId target;
		};
		struct JumpTable
		{
			langutil::DebugData::ConstPtr debugData{};
			ValueId value;
			std::map<u256, BlockId> cases;
			BlockId defaultCase;
		};
		struct FunctionReturn
		{
			langutil::DebugData::ConstPtr debugData{};
			std::vector<ValueId> returnValues;
		};
		struct Terminated {};
		langutil::DebugData::ConstPtr debugData;
		std::set<BlockId> entries;
		std::set<ValueId> phis;
		std::vector<Operation> operations;
		std::variant<MainExit, Jump, ConditionalJump, JumpTable, FunctionReturn, Terminated> exit = MainExit{};
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
			else if (auto* jumpTable = std::get_if<JumpTable>(&exit))
			{
				for (auto _case: jumpTable->cases | ranges::views::values)
					_callable(_case);
				_callable(jumpTable->defaultCase);
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
		m_blocks.emplace_back(BasicBlock{std::move(_debugData), {}, {}, {}, BasicBlock::Terminated{}});
		return blockId;
	}
	BasicBlock& block(BlockId _id) { return m_blocks.at(_id.value); }
	BasicBlock const& block(BlockId _id) const { return m_blocks.at(_id.value); }
	size_t numBlocks() const { return m_blocks.size(); }

private:
	std::vector<BasicBlock> m_blocks;
public:
	struct LiteralValue {
		langutil::DebugData::ConstPtr debugData;
		u256 value;
	};
	struct VariableValue {
		langutil::DebugData::ConstPtr debugData;
		BlockId definingBlock;
	};
	struct PhiValue {
		langutil::DebugData::ConstPtr debugData;
		BlockId block;
		std::vector<ValueId> arguments;
	};
	struct UnreachableValue {};
	ValueId newPhi(BlockId const _definingBlock)
	{
		auto const& block = m_blocks.at(_definingBlock.value);
		m_phis.emplace_back(PhiValue{debugDataOf(block), _definingBlock, std::vector<ValueId>{}});
		auto const value = m_phis.size() - 1;
		yulAssert(value < std::numeric_limits<ValueId::ValueType>::max());
		return ValueId::makePhi(static_cast<ValueId::ValueType>(value));
	}
	ValueId newVariable(BlockId const _definingBlock)
	{
		auto const& block = m_blocks.at(_definingBlock.value);
		m_variables.emplace_back(VariableValue{debugDataOf(block), _definingBlock});
		auto const value = m_variables.size() - 1;
		yulAssert(value < std::numeric_limits<ValueId::ValueType>::max());
		return ValueId::makeVariable(static_cast<ValueId::ValueType>(value));
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


		m_literals.emplace_back(LiteralValue{std::move(_debugData), std::move(_value)});
		auto const value = m_literals.size() - 1;
		yulAssert(value < std::numeric_limits<ValueId::ValueType>::max());
		auto const literalId = ValueId::makeLiteral(static_cast<ValueId::ValueType>(value));
		m_literalMapping.emplace(_value, literalId);
		return literalId;
	}

	size_t phiArgumentIndex(BlockId const _source, BlockId const _target) const
	{
		auto const& targetBlock = block(_target);
		auto idx = util::findOffset(targetBlock.entries, _source);
		yulAssert(idx, fmt::format("Target block {} not found as entry in one of the exits of the current block {}.", _target.value, _source.value));
		return *idx;
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
	langutil::DebugData::ConstPtr debugData;
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
