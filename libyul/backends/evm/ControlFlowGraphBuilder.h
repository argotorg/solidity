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
 * Transformation of a Yul AST into a control flow graph.
 */
#pragma once

#include <libyul/backends/evm/ControlFlowGraph.h>
#include <libyul/ControlFlowSideEffects.h>

#include <libsolutil/UnorderedContainers.h>

#include <liblangutil/EVMVersion.h>

#include <cstdint>
#include <optional>
#include <span>

namespace solidity::yul
{

class ControlFlowGraphBuilder
{
public:
	ControlFlowGraphBuilder(ControlFlowGraphBuilder const&) = delete;
	ControlFlowGraphBuilder& operator=(ControlFlowGraphBuilder const&) = delete;
	/// @param _expectedExecutionsPerDeployment Estimated number of times this code executes per
	/// deployment (nullopt for creation code, where this concept does not apply). Used to decide
	/// whether large ``switch`` statements are worth lowering as a binary search tree of
	/// ``gt``-keyed comparisons instead of a linear chain of ``eq`` comparisons.
	static std::unique_ptr<CFG> build(
		AsmAnalysisInfo const& _analysisInfo,
		Dialect const& _dialect,
		Block const& _block,
		std::optional<std::uint64_t> _expectedExecutionsPerDeployment
	);

	StackSlot operator()(Expression const& _expression);
	StackSlot operator()(Literal const& _literal);
	StackSlot operator()(Identifier const& _identifier);
	StackSlot operator()(FunctionCall const&);

	void operator()(VariableDeclaration const& _varDecl);
	void operator()(Assignment const& _assignment);
	void operator()(ExpressionStatement const& _statement);

	void operator()(Block const& _block);

	void operator()(If const& _if);
	void operator()(Switch const& _switch);
	void operator()(ForLoop const&);
	void operator()(Break const&);
	void operator()(Continue const&);
	void operator()(Leave const&);
	void operator()(FunctionDefinition const&);

private:
	ControlFlowGraphBuilder(
		CFG& _graph,
		AsmAnalysisInfo const& _analysisInfo,
		util::unordered_flat_map<FunctionDefinition const*, ControlFlowSideEffects> const& _functionSideEffects,
		Dialect const& _dialect,
		std::optional<std::uint64_t> _expectedExecutionsPerDeployment
	);
	void registerFunction(FunctionDefinition const& _function);
	Stack const& visitFunctionCall(FunctionCall const&);
	Stack visitAssignmentRightHandSide(Expression const& _expression, size_t _expectedSlotCount);

	Scope::Function const& lookupFunction(YulName _name) const;
	Scope::Variable const& lookupVariable(YulName _name) const;
	/// Resets m_currentBlock to enforce a subsequent explicit reassignment.
	void makeConditionalJump(
		langutil::DebugData::ConstPtr _debugData,
		StackSlot _condition,
		CFG::BasicBlock& _nonZero,
		CFG::BasicBlock& _zero
	);
	void jump(
		langutil::DebugData::ConstPtr _debugData,
		CFG::BasicBlock& _target,
		bool _backwards = false
	);

	/// @returns true if splitting @a _cases (sorted by value, non-empty) into a gt(expr, pivot)
	/// binary search tree at this level is worth the extra code size.
	bool shouldSplitSwitch(std::span<Case const* const> _cases, Block const* _defaultBody) const;

	/// Builds and returns a block running @a _defaultBody once, so every switch branch that
	/// falls through to the default case can jump to the same block instead of each
	/// regenerating its own copy.
	CFG::BasicBlock& buildDefaultBlock(
		Block const& _defaultBody,
		CFG::BasicBlock& _afterSwitch,
		langutil::DebugData::ConstPtr _switchDebugData
	);

	/// Recursively lowers a sorted, non-empty slice of literal switch cases into either a
	/// linear chain (buildLinearSwitchChain) or a gt(expr, pivot) binary search tree.
	void buildSwitchTree(
		std::span<Case const* const> _cases,
		VariableSlot const& _ghostVarSlot,
		YulName _ghostVariableName,
		Block const* _defaultBody,
		CFG::BasicBlock* _defaultBlock,
		CFG::BasicBlock& _afterSwitch,
		langutil::DebugData::ConstPtr _switchDebugData
	);

	/// Builds a linear if-elif chain of eq(literal, expr) comparisons for @a _cases, in the
	/// given order, falling through to @a _defaultBlock (if non-null) when none match.
	void buildLinearSwitchChain(
		std::span<Case const* const> _cases,
		VariableSlot const& _ghostVarSlot,
		YulName _ghostVariableName,
		CFG::BasicBlock* _defaultBlock,
		CFG::BasicBlock& _afterSwitch,
		langutil::DebugData::ConstPtr _switchDebugData
	);

	CFG& m_graph;
	AsmAnalysisInfo const& m_info;
	util::unordered_flat_map<FunctionDefinition const*, ControlFlowSideEffects> const& m_functionSideEffects;
	Dialect const& m_dialect;
	/// Handle of the EVM ``gt`` builtin, if @a m_dialect is an EVMDialect that provides one.
	/// Large switches are only split into a binary search tree when this is set; otherwise
	/// they always fall back to the linear eq-chain (today's behavior).
	std::optional<BuiltinHandle> m_gtHandle;
	std::uint64_t m_runs = 1;
	bool m_isCreation = true;
	langutil::EVMVersion m_evmVersion;
	CFG::BasicBlock* m_currentBlock = nullptr;
	Scope* m_scope = nullptr;
	struct ForLoopInfo
	{
		std::reference_wrapper<CFG::BasicBlock> afterLoop;
		std::reference_wrapper<CFG::BasicBlock> post;
	};
	std::optional<ForLoopInfo> m_forLoopInfo;
	std::optional<CFG::FunctionInfo*> m_currentFunction;
};

}
