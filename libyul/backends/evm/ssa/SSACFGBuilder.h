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
* Transformation of a Yul AST into a control flow graph in Phi/Upsilon SSA form.
*
* SSA construction is based on https://doi.org/10.1007/978-3-642-37051-9_6
* Braun, Matthias, et al. "Simple and efficient construction of static single assignment form."
* Compiler Construction: 22nd International Conference, CC 2013,
* ETAPS 2013, Rome, Italy, March 16-24, 2013. Proceedings 22. Springer Berlin Heidelberg, 2013.
*
* We have small deviations in Algorithms 2 and 4, as the paper's presentation leads to trivial phis being spuriously
* removed from not yet sealed blocks via a call to addPhiOperands in Algorithm 4. Instead, we perform the deletion
* of trivial phis only after a block has been sealed, i.e., all block's predecessors are present.
*
* The IR uses Phi/Upsilon form (see https://gist.github.com/pizlonator/cf1e72b8600b1437dda8153ea3fdb963) rather than
* traditional phi nodes with explicit argument lists.
* In Phi/Upsilon form each predecessor block emits an Upsilon operation that records the phi pre-image
* for that edge; the Phi itself carries no argument list. This makes the phi pre-image relationship
* explicit in the IR and means that adding or removing a predecessor never requires reindexing
* phi arguments.
*/
#pragma once

#include <libyul/backends/evm/ssa/ControlFlow.h>
#include <libyul/ControlFlowSideEffectsCollector.h>
#include <libyul/backends/evm/ssa/SSACFG.h>
#include <stack>

namespace solidity::yul::ssa
{

class SSACFGBuilder
{
	SSACFGBuilder(
		ControlFlow& _controlFlow,
		SSACFG& _graph,
		AsmAnalysisInfo const& _analysisInfo,
		ControlFlowSideEffectsCollector const& _sideEffects,
		Dialect const& _dialect,
		bool _keepLiteralAssignments,
		bool _generateDebugInfo
	);
public:
	SSACFGBuilder(SSACFGBuilder const&) = delete;
	SSACFGBuilder& operator=(SSACFGBuilder const&) = delete;
	static std::unique_ptr<ControlFlow> build(
		AsmAnalysisInfo const& _analysisInfo,
		Dialect const& _dialect,
		Block const& _block,
		bool _keepLiteralAssignments,
		bool _generateDebugInfo = true
	);

	void operator()(ExpressionStatement const& _statement);
	void operator()(Assignment const& _assignment);
	void operator()(VariableDeclaration const& _varDecl);

	void operator()(FunctionDefinition const&);
	void operator()(If const& _if);
	void operator()(Switch const& _switch);
	void operator()(ForLoop const&);
	void operator()(Break const&);
	void operator()(Continue const&);
	void operator()(Leave const&);

	void operator()(Block const& _block);

	SSACFG::ValueId operator()(FunctionCall const& _call);
	SSACFG::ValueId operator()(Identifier const& _identifier);
	SSACFG::ValueId operator()(Literal const& _literal);

private:
	void cleanUnreachable();
	SSACFG::ValueId tryRemoveTrivialPhi(SSACFG::ValueId _phi);
	void assign(std::vector<std::reference_wrapper<Scope::Variable const>> _variables, Expression const* _expression);
	std::vector<SSACFG::ValueId> visitFunctionCall(FunctionCall const& _call);
	void registerFunctionDefinition(FunctionDefinition const& _functionDefinition);
	void buildFunctionGraph(Scope::Function const* _function, FunctionDefinition const* _functionDefinition);

	SSACFG::ValueId zero();
	SSACFG::ValueId readVariable(Scope::Variable const& _variable, SSACFG::BlockId _block);
	SSACFG::ValueId readVariableRecursive(Scope::Variable const& _variable, SSACFG::BlockId _block);
	/// Emit upsilons in each predecessor of _phi's block, recording the phi pre-images.
	void addPhiOperands(Scope::Variable const& _variable, SSACFG::ValueId _phi);
	/// Emit a single Upsilon(_value -> _phi) into block _block.
	void emitUpsilon(SSACFG::BlockId _block, SSACFG::ValueId _value, SSACFG::ValueId _phi);
	void writeVariable(Scope::Variable const& _variable, SSACFG::BlockId _block, SSACFG::ValueId _value);

	ControlFlow& m_controlFlow;
	SSACFG& m_graph;
	AsmAnalysisInfo const& m_info;
	ControlFlowSideEffectsCollector const& m_sideEffects;
	Dialect const& m_dialect;
	bool const m_keepLiteralAssignments;
	bool const m_generateDebugInfo;
	std::vector<std::tuple<Scope::Function const*, FunctionDefinition const*>> m_functionDefinitions;
	SSACFG::BlockId m_currentBlock;
	SSACFG::BasicBlock& currentBlock() { return m_graph.block(m_currentBlock); }
	langutil::DebugData::ConstPtr currentBlockDebugData() const
	{
		return m_graph.debugInfo ? m_graph.debugInfo->blockDebugData(m_currentBlock) : nullptr;
	}
	Scope* m_scope = nullptr;
	Scope::Function const& lookupFunction(YulName _name) const;
	Scope::Variable const& lookupVariable(YulName _name) const;

	struct BlockInfo {
		bool sealed = false;
		std::vector<std::tuple<SSACFG::ValueId, std::reference_wrapper<Scope::Variable const>>> incompletePhis;
	};
	std::vector<BlockInfo> m_blockInfo;

	BlockInfo& blockInfo(SSACFG::BlockId _block)
	{
		if (_block.value >= m_blockInfo.size())
			m_blockInfo.resize(_block.value + 1, {});
		return m_blockInfo[_block.value];
	}
	void sealBlock(SSACFG::BlockId _block);

	std::map<
		Scope::Variable const*,
		std::vector<std::optional<SSACFG::ValueId>>
	> m_currentDef;

	struct ForLoopInfo {
		SSACFG::BlockId breakBlock;
		SSACFG::BlockId continueBlock;
	};
	std::stack<ForLoopInfo> m_forLoopInfo;

	std::optional<SSACFG::ValueId>& currentDef(Scope::Variable const& _variable, SSACFG::BlockId _block)
	{
		auto& varDefs = m_currentDef[&_variable];
		if (varDefs.size() <= _block.value)
			varDefs.resize(_block.value + 1);
		return varDefs.at(_block.value);
	}

	void conditionalJump(
		langutil::DebugData::ConstPtr _debugData,
		SSACFG::ValueId _condition,
		SSACFG::BlockId _nonZero,
		SSACFG::BlockId _zero
	);

	void jump(
		langutil::DebugData::ConstPtr _debugData,
		SSACFG::BlockId _target
	);

	FunctionDefinition const* findFunctionDefinition(Scope::Function const* _function) const;
};

}
