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

#include <libyul/backends/evm/ssa/SSACFGBuilder.h>

#include <libyul/backends/evm/ssa/ControlFlowGraphs.h>

#include <libyul/AST.h>
#include <libyul/ControlFlowSideEffectsCollector.h>
#include <libyul/Exceptions.h>
#include <libyul/Utilities.h>

#include <libsolutil/Algorithms.h>
#include <libsolutil/StringUtils.h>
#include <libsolutil/Visitor.h>

#include <range/v3/range/conversion.hpp>
#include <range/v3/view/drop_last.hpp>
#include <range/v3/view/enumerate.hpp>
#include <range/v3/view/filter.hpp>
#include <range/v3/view/reverse.hpp>
#include <range/v3/view/transform.hpp>
#include <range/v3/view/zip.hpp>

using namespace solidity;
using namespace solidity::yul;
using namespace solidity::yul::ssa;

SSACFGBuilder::SSACFGBuilder(
	ControlFlowGraphs& _controlFlow,
	SSACFG& _graph,
	AsmAnalysisInfo const& _analysisInfo,
	ControlFlowSideEffectsCollector const& _sideEffects,
	EVMDialect const& _dialect,
	bool _generateDebugInfo,
	FunctionRegistry& _functionRegistry
):
	m_controlFlow(_controlFlow),
	m_graph(_graph),
	m_info(_analysisInfo),
	m_sideEffects(_sideEffects),
	m_dialect(_dialect),
	m_generateDebugInfo(_generateDebugInfo),
	m_functionRegistry(_functionRegistry),
	m_memoryGuardHandle([&] {
		auto const memoryGuardHandle = m_dialect.findBuiltin("memoryguard");
		yulAssert(memoryGuardHandle.has_value(), "We only support EVM dialects that contain memoryguard");
		return *memoryGuardHandle;
	}())
{
}

std::unique_ptr<ControlFlowGraphs> SSACFGBuilder::build(
	AsmAnalysisInfo const& _analysisInfo,
	EVMDialect const& _dialect,
	Block const& _block,
	bool _generateDebugInfo
)
{
	ControlFlowSideEffectsCollector sideEffects(_dialect, _block);

	auto controlFlowGraphs = std::make_unique<ControlFlowGraphs>();
	controlFlowGraphs->functionGraphs.emplace_back(std::make_unique<SSACFG>(
		_dialect,
		_generateDebugInfo ? std::make_unique<SSACFGDebugInfo>() : nullptr
	));
	SSACFG& mainGraph = *controlFlowGraphs->functionGraphs.back();
	FunctionRegistry functionRegistry;
	SSACFGBuilder builder(*controlFlowGraphs, mainGraph, _analysisInfo, sideEffects, _dialect, _generateDebugInfo, functionRegistry);
	builder.m_currentBlock = mainGraph.makeBlock(debugDataOf(_block));
	builder.sealBlock(builder.m_currentBlock);
	builder(_block);
	if (!builder.blockInfo(builder.m_currentBlock).sealed)
		builder.sealBlock(builder.m_currentBlock);
	mainGraph.block(builder.m_currentBlock).exit = SSACFG::BasicBlock::MainExit{};
	return controlFlowGraphs;
}


void SSACFGBuilder::buildFunctionGraph(
	Scope::Function const* _function,
	FunctionDefinition const* _functionDefinition
)
{
	// The graph slot and the FunctionGraphID have already been allocated in
	// `registerFunctionDefinition`; this call builds the body into that slot.
	auto const regIt = m_functionRegistry.find(_function);
	yulAssert(regIt != m_functionRegistry.end(), "Function graph must be registered before building.");
	auto& cfg = *m_controlFlow.functionGraphs[regIt->second.id];

	yulAssert(m_info.scopes.at(&_functionDefinition->body), "");
	Scope* virtualFunctionScope = m_info.scopes.at(m_info.virtualBlocks.at(_functionDefinition).get()).get();
	yulAssert(virtualFunctionScope, "");

	cfg.entry = cfg.makeBlock(debugDataOf(_functionDefinition->body));
	auto argumentBindings = _functionDefinition->parameters | ranges::views::transform([&](auto const& _param) {
		auto const& var = std::get<Scope::Variable>(virtualFunctionScope->identifiers.at(_param.name));
		// Note: cannot use std::make_tuple since it unwraps reference wrappers.
		return std::tuple{std::cref(var), cfg.newFunctionArgument()};
	}) | ranges::to<std::vector>;
	auto returnVars = _functionDefinition->returnVariables | ranges::views::transform([&](auto const& _param) {
		return std::cref(std::get<Scope::Variable>(virtualFunctionScope->identifiers.at(_param.name)));
	}) | ranges::to<std::vector<std::reference_wrapper<Scope::Variable const>>>();

	if (cfg.debugInfo)
		cfg.debugInfo->graphDebugData = _functionDefinition->debugData;
	cfg.canContinue = m_sideEffects.functionSideEffects().at(_functionDefinition).canContinue;
	cfg.arguments = argumentBindings
		| ranges::views::transform([](auto const& _binding) { return std::get<1>(_binding); })
		| ranges::to<std::vector>;

	SSACFGBuilder builder(m_controlFlow, cfg, m_info, m_sideEffects, m_dialect, m_generateDebugInfo, m_functionRegistry);
	builder.m_currentBlock = cfg.entry;
	builder.m_currentReturnVars = returnVars;
	for (auto&& [var, varId]: argumentBindings)
		builder.currentDef(var, cfg.entry) = varId;
	for (auto const& var: returnVars)
		builder.currentDef(var.get(), cfg.entry) = builder.zero();
	builder.sealBlock(cfg.entry);
	builder(_functionDefinition->body);
	cfg.exits.insert(builder.m_currentBlock);
	// Artificial explicit function exit (`leave`) at the end of the body.
	builder(Leave{debugDataOf(*_functionDefinition)});
}

void SSACFGBuilder::operator()(ExpressionStatement const& _expressionStatement)
{
	auto const* functionCall = std::get_if<FunctionCall>(&_expressionStatement.expression);
	yulAssert(functionCall);
	visitFunctionCall(*functionCall);
}

void SSACFGBuilder::operator()(Assignment const& _assignment)
{
	assign(
		_assignment.variableNames | ranges::views::transform([&](auto& _var) { return std::ref(lookupVariable(_var.name)); }) | ranges::to<std::vector>,
		_assignment.value.get()
	);
}

void SSACFGBuilder::operator()(VariableDeclaration const& _variableDeclaration)
{
	assign(
		_variableDeclaration.variables | ranges::views::transform([&](auto& _var) { return std::ref(lookupVariable(_var.name)); }) | ranges::to<std::vector>,
		_variableDeclaration.value.get()
	);
}

void SSACFGBuilder::operator()(FunctionDefinition const& _functionDefinition)
{
	Scope::Function const& function = lookupFunction(_functionDefinition.name);
	buildFunctionGraph(&function, &_functionDefinition);
}

void SSACFGBuilder::operator()(If const& _if)
{
	std::optional<bool> constantCondition;
	if (auto const* literalCondition = std::get_if<Literal>(_if.condition.get()))
		constantCondition = literalCondition->value.value() != 0;
	// deal with literal (constant) conditions explicitly
	if (constantCondition)
	{
		if (*constantCondition)
			// Always true - skip conditional, just execute if branch
			(*this)(_if.body);
	}
	else
	{
		auto condition = std::visit(*this, *_if.condition);
		auto ifBranch = m_graph.makeBlock(debugDataOf(_if.body));
		auto afterIf = m_graph.makeBlock(currentBlockDebugData());
		conditionalJump(
			debugDataOf(_if),
			condition,
			ifBranch,
			afterIf
		);
		sealBlock(ifBranch);
		m_currentBlock = ifBranch;
		(*this)(_if.body);
		jump(debugDataOf(_if.body), afterIf);
		sealBlock(afterIf);
	}
}

void SSACFGBuilder::operator()(Switch const& _switch)
{
	auto expression = std::visit(*this, *_switch.expression);

	if (auto const* constantExpression = std::get_if<Literal>(_switch.expression.get()))
	{
		Case const* matchedCase = nullptr;
		// select case that matches (or default if available)
		for (auto const& switchCase: _switch.cases)
		{
			if (!switchCase.value)
				matchedCase = &switchCase;
			if (switchCase.value && switchCase.value->value.value() == constantExpression->value.value())
			{
				matchedCase = &switchCase;
				break;
			}
		}
		if (matchedCase)
		{
			// inject directly into the current block
			(*this)(matchedCase->body);
		}
		return;
	}

	std::optional<BuiltinHandle> equalityBuiltinHandle = m_dialect.equalityFunctionHandle();
	yulAssert(equalityBuiltinHandle);

	auto const& equalityBuiltin = m_dialect.builtin(*equalityBuiltinHandle);
	auto makeValueCompare = [&](Case const& _case) {
		return m_graph.makeBuiltinCallWithProjections(
			m_currentBlock,
			SSACFG::BuiltinCall{*equalityBuiltinHandle, {}},
			{m_graph.newLiteral(debugDataOf(_case), _case.value->value.value()), expression},
			static_cast<InstructionStore::NumReturnsSizeType>(equalityBuiltin.numReturns),
			debugDataOf(_case)
		);
	};

	auto afterSwitch = m_graph.makeBlock(currentBlockDebugData());
	yulAssert(!_switch.cases.empty(), "");
	for (auto const& switchCase: _switch.cases | ranges::views::drop_last(1))
	{
		yulAssert(switchCase.value, "");
		auto caseBranch = m_graph.makeBlock(debugDataOf(switchCase.body));
		auto elseBranch = m_graph.makeBlock(debugDataOf(_switch));

		conditionalJump(debugDataOf(switchCase), makeValueCompare(switchCase), caseBranch, elseBranch);
		sealBlock(caseBranch);
		sealBlock(elseBranch);
		m_currentBlock = caseBranch;
		(*this)(switchCase.body);
		jump(debugDataOf(switchCase.body), afterSwitch);
		m_currentBlock = elseBranch;
	}
	Case const& switchCase = _switch.cases.back();
	if (switchCase.value)
	{
		auto caseBranch = m_graph.makeBlock(debugDataOf(switchCase.body));
		conditionalJump(debugDataOf(switchCase), makeValueCompare(switchCase), caseBranch, afterSwitch);
		sealBlock(caseBranch);
		m_currentBlock = caseBranch;
	}
	(*this)(switchCase.body);
	jump(debugDataOf(switchCase.body), afterSwitch);
	sealBlock(afterSwitch);
}
void SSACFGBuilder::operator()(ForLoop const& _loop)
{
	ScopedSaveAndRestore scopeRestore(m_scope, m_info.scopes.at(&_loop.pre).get());
	(*this)(_loop.pre);
	auto preLoopDebugData = currentBlockDebugData();

	std::optional<bool> constantCondition;
	if (auto const* literalCondition = std::get_if<Literal>(_loop.condition.get()))
		constantCondition = literalCondition->value.value() != 0;

	SSACFG::BlockId loopCondition = m_graph.makeBlock(debugDataOf(*_loop.condition));
	SSACFG::BlockId loopBody = m_graph.makeBlock(debugDataOf(_loop.body));
	SSACFG::BlockId post = m_graph.makeBlock(debugDataOf(_loop.post));
	SSACFG::BlockId afterLoop = m_graph.makeBlock(preLoopDebugData);

	class ForLoopInfoScope {
	public:
		ForLoopInfoScope(std::stack<ForLoopInfo>& _info, SSACFG::BlockId _breakBlock, SSACFG::BlockId _continueBlock): m_info(_info)
		{
			m_info.push(ForLoopInfo{_breakBlock, _continueBlock});
		}
		~ForLoopInfoScope() {
			m_info.pop();
		}
	private:
		std::stack<ForLoopInfo>& m_info;
	} forLoopInfoScope(m_forLoopInfo, afterLoop, post);

	if (constantCondition.has_value())
	{
		std::visit(*this, *_loop.condition);
		if (*constantCondition)
		{
			jump(debugDataOf(*_loop.condition), loopBody);
			(*this)(_loop.body);
			jump(debugDataOf(_loop.body), post);
			sealBlock(post);
			(*this)(_loop.post);
			jump(debugDataOf(_loop.post), loopBody);
			sealBlock(loopBody);
		}
		else
			jump(debugDataOf(*_loop.condition), afterLoop);
	}
	else
	{
		jump(debugDataOf(_loop.pre), loopCondition);
		auto condition = std::visit(*this, *_loop.condition);
		conditionalJump(debugDataOf(*_loop.condition), condition, loopBody, afterLoop);
		sealBlock(loopBody);
		m_currentBlock = loopBody;
		(*this)(_loop.body);
		jump(debugDataOf(_loop.body), post);
		sealBlock(post);
		(*this)(_loop.post);
		jump(debugDataOf(_loop.post), loopCondition);
		sealBlock(loopCondition);
	}

	sealBlock(afterLoop);
	m_currentBlock = afterLoop;
}

void SSACFGBuilder::operator()(Break const& _break)
{
	yulAssert(!m_forLoopInfo.empty());
	auto savedBlockDebugData = currentBlockDebugData();
	jump(debugDataOf(_break), m_forLoopInfo.top().breakBlock);
	m_currentBlock = m_graph.makeBlock(savedBlockDebugData);
	sealBlock(m_currentBlock);
}

void SSACFGBuilder::operator()(Continue const& _continue)
{
	yulAssert(!m_forLoopInfo.empty());
	auto const savedBlockDebugData = currentBlockDebugData();
	jump(debugDataOf(_continue), m_forLoopInfo.top().continueBlock);
	m_currentBlock = m_graph.makeBlock(savedBlockDebugData);
	sealBlock(m_currentBlock);
}

void SSACFGBuilder::operator()(Leave const& _leaveStatement)
{
	auto const savedBlockDebugData = currentBlockDebugData();
	if (m_graph.debugInfo)
		m_graph.debugInfo->setExitDebugData(m_currentBlock, debugDataOf(_leaveStatement));
	currentBlock().exit = SSACFG::BasicBlock::FunctionReturn{
		m_currentReturnVars | ranges::views::transform([&](auto _var) {
			return readVariable(_var, m_currentBlock);
		}) | ranges::to<std::vector>
	};
	m_currentBlock = m_graph.makeBlock(savedBlockDebugData);
	sealBlock(m_currentBlock);
}

void SSACFGBuilder::registerFunctionDefinition(FunctionDefinition const& _functionDefinition)
{
	yulAssert(m_scope, "");
	yulAssert(m_scope->identifiers.count(_functionDefinition.name), "");
	auto& function = std::get<Scope::Function>(m_scope->identifiers.at(_functionDefinition.name));

	// Allocate the graph slot up front so sibling functions (and mutually-recursive pairs) can
	// reference this function by its FunctionGraphID when their bodies are built later.
	m_controlFlow.functionGraphs.emplace_back(std::make_unique<SSACFG>(
		m_dialect,
		m_generateDebugInfo ? std::make_unique<SSACFGDebugInfo>() : nullptr
	));
	auto const graphID = static_cast<FunctionGraphID>(m_controlFlow.functionGraphs.size() - 1);
	auto& cfg = *m_controlFlow.functionGraphs.back();
	cfg.name = function.name.str();
	cfg.numReturns = _functionDefinition.returnVariables.size();
	m_functionRegistry[&function] = {graphID, &_functionDefinition};
}

void SSACFGBuilder::operator()(Block const& _block)
{
	ScopedSaveAndRestore saveScope(m_scope, m_info.scopes.at(&_block).get());
	// gather all function definitions so that they are visible to each other's subgraphs
	static constexpr auto functionDefinitionFilter = ranges::views::filter(
		[](auto const& _statement) { return std::holds_alternative<FunctionDefinition>(_statement); }
	);
	for (auto const& statement: _block.statements | functionDefinitionFilter)
		registerFunctionDefinition(std::get<FunctionDefinition>(statement));
	// now visit the rest
	for (auto const& statement: _block.statements)
		std::visit(*this, statement);
}

InstId SSACFGBuilder::operator()(FunctionCall const& _call)
{
	// Single-output expression context: the call's InstId is itself the value handle.
	return visitFunctionCall(_call);
}

InstId SSACFGBuilder::operator()(Identifier const& _identifier)
{
	auto const& var = lookupVariable(_identifier.name);
	return readVariable(var, m_currentBlock);
}

InstId SSACFGBuilder::operator()(Literal const& _literal)
{
	return m_graph.newLiteral(currentBlockDebugData(), _literal.value.value());
}

void SSACFGBuilder::assign(std::vector<std::reference_wrapper<Scope::Variable const>> _variables, Expression const* _expression)
{
	if (auto const* functionCall = std::get_if<FunctionCall>(_expression))
	{
		InstId const callId = visitFunctionCall(*functionCall);
		if (m_graph.isUnreachable(callId))
		{
			// The callee did not continue: post-call block is unreachable. Bind variables to unreachable.
			for (auto const& var: _variables)
				writeVariable(var, m_currentBlock, callId);
		}
		else
		{
			yulAssert(m_graph.numReturnsOf(callId) == _variables.size());
			auto const outputs = m_graph.outputsOf(callId);
			yulAssert(outputs.size() == _variables.size());
			for (auto const& [var, output]: ranges::views::zip(_variables, outputs))
				writeVariable(var, m_currentBlock, output);
		}
		return;
	}
	auto const rhs = _expression ?
		std::vector{std::visit(*this, *_expression)} :
		std::vector(_variables.size(), zero());
	yulAssert(rhs.size() == _variables.size());
	for (auto const& [var, value]: ranges::zip_view(_variables, rhs))
		writeVariable(var, m_currentBlock, value);
}

InstId SSACFGBuilder::visitFunctionCall(FunctionCall const& _call)
{
	bool canContinue = true;
	InstId const id = std::visit(solidity::util::GenericVisitor{
		[&](BuiltinName const& _builtinName) -> InstId
		{
			// memoryguard(N) is represented as a dedicated MemoryGuard Inst; the boundary value lives in the
			// corresponding ControlFlowGraphs instance
			if (_builtinName.handle == m_memoryGuardHandle)
			{
				yulAssert(_call.arguments.size() == 1);
				Literal const* literal = std::get_if<Literal>(&_call.arguments.front());
				yulAssert(literal && literal->kind == LiteralKind::Number);
				u256 const value = literal->value.value();
				if (m_controlFlow.memoryGuard)
					yulAssert(
						*m_controlFlow.memoryGuard == value,
						"memoryguard: inconsistent literal across subobject"
					);
				else
					m_controlFlow.memoryGuard = value;
				canContinue = m_dialect.builtin(m_memoryGuardHandle).controlFlowSideEffects.canContinue;
				return m_graph.makeMemoryGuard(m_currentBlock, debugDataOf(_call));
			}

			auto const& builtin = m_dialect.builtin(_builtinName.handle);
			yulAssert(_call.arguments.size() == builtin.numParameters);
			std::vector<Literal> literalArguments;
			for (auto&& [kind, arg]: ranges::views::zip(builtin.literalArguments, _call.arguments))
				if (kind.has_value())
				{
					yulAssert(std::holds_alternative<Literal>(arg));
					literalArguments.emplace_back(std::get<Literal>(arg));
				}
			std::vector<InstId> inputs;
			for (auto&& [idx, arg]: _call.arguments | ranges::views::enumerate | ranges::views::reverse)
				if (!builtin.literalArgument(idx).has_value())
					inputs.emplace_back(std::visit(*this, arg));
			canContinue = builtin.controlFlowSideEffects.canContinue;
			return m_graph.makeBuiltinCallWithProjections(
				m_currentBlock,
				SSACFG::BuiltinCall{_builtinName.handle, std::move(literalArguments)},
				std::move(inputs),
				static_cast<InstructionStore::NumReturnsSizeType>(builtin.numReturns),
				debugDataOf(_call)
			);
		},
		[&](Identifier const& _identifier) -> InstId
		{
			YulName const& functionName = _identifier.name;
			Scope::Function const& function = lookupFunction(functionName);
			auto const calleeIt = m_functionRegistry.find(&function);
			yulAssert(calleeIt != m_functionRegistry.end(), "Called function has no registered graph id.");
			canContinue = m_sideEffects.functionSideEffects().at(calleeIt->second.definition).canContinue;
			std::vector<InstId> inputs;
			for (auto const& arg: _call.arguments | ranges::views::reverse)
				inputs.emplace_back(std::visit(*this, arg));
			return m_graph.makeCallWithProjections(
				m_currentBlock,
				SSACFG::Call{calleeIt->second.id, canContinue, function.numReturns},
				std::move(inputs),
				static_cast<InstructionStore::NumReturnsSizeType>(function.numReturns),
				debugDataOf(_call)
			);
		}
	}, _call.functionName);
	if (canContinue)
		return id;
	// `id` lives in the now-Terminated call block and won't dominate the successor,
	// so terminate, open a fresh successor and signal non-continuation via unreachableValue.
	currentBlock().exit = SSACFG::BasicBlock::Terminated{};
	m_currentBlock = m_graph.makeBlock(currentBlockDebugData());
	sealBlock(m_currentBlock);
	return m_graph.unreachableValue();
}

InstId SSACFGBuilder::zero()
{
	return m_graph.newLiteral(currentBlockDebugData(), 0u);
}

InstId SSACFGBuilder::readVariable(Scope::Variable const& _variable, SSACFG::BlockId _block)
{
	auto const& def = currentDef(_variable, _block);
	if (def.hasValue())
		return def;
	return readVariableRecursive(_variable, _block);
}

InstId SSACFGBuilder::readVariableRecursive(Scope::Variable const& _variable, SSACFG::BlockId _block)
{
	auto& block = m_graph.block(_block);
	auto& info = blockInfo(_block);

	InstId val;
	if (!info.sealed)
	{
		// incomplete block: create a phi and defer upsilon emission until the block is sealed
		val = m_graph.newPhi(_block);
		info.incompletePhis.emplace_back(val, _variable);
	}
	else if (block.entries.size() == 1)
		// one predecessor: no phi needed
		val = readVariable(_variable, *block.entries.begin());
	else
	{
		// Break potential cycles with an argument-less phi; emit upsilons for all predecessors.
		val = m_graph.newPhi(_block);
		writeVariable(_variable, _block, val);
		addPhiOperands(_variable, val);
	}
	writeVariable(_variable, _block, val);
	return val;
}

void SSACFGBuilder::addPhiOperands(Scope::Variable const& _variable, InstId _phi)
{
	SSACFG::BlockId const phiBlock = m_graph.inst(_phi).block;
	for (auto const& pred: m_graph.block(phiBlock).entries)
	{
		auto const val = readVariable(_variable, pred);
		emitUpsilon(pred, val, _phi);
	}
}

void SSACFGBuilder::emitUpsilon(SSACFG::BlockId _block, InstId _value, InstId _phi)
{
	yulAssert(m_graph.isPhi(_phi));
	m_graph.emitUpsilon(_block, _value, _phi);
}

void SSACFGBuilder::writeVariable(Scope::Variable const& _variable, SSACFG::BlockId _block, InstId _value)
{
	currentDef(_variable, _block) = _value;
}

Scope::Function const& SSACFGBuilder::lookupFunction(YulName _name) const
{
	Scope::Function const* function = nullptr;
	yulAssert(m_scope->lookup(_name, solidity::util::GenericVisitor{
		[](Scope::Variable&) { yulAssert(false, "Expected function name."); },
		[&](Scope::Function& _function) { function = &_function; }
	}), "Function name not found.");
	yulAssert(function, "");
	return *function;
}

Scope::Variable const& SSACFGBuilder::lookupVariable(YulName _name) const
{
	yulAssert(m_scope, "");
	Scope::Variable const* var = nullptr;
	if (m_scope->lookup(_name, solidity::util::GenericVisitor{
		[&](Scope::Variable const& _var) { var = &_var; },
		[](Scope::Function const&)
		{
			yulAssert(false, "Function not removed during desugaring.");
		}
	}))
	{
		yulAssert(var);
		return *var;
	};
	yulAssert(false, "External identifier access unimplemented.");
}

void SSACFGBuilder::sealBlock(SSACFG::BlockId _block)
{
	auto& info = blockInfo(_block);
	yulAssert(!info.sealed, "Trying to seal already sealed block.");
	// emit upsilons for all incomplete phis before marking the block as sealed
	for (auto&& [phi, variable] : info.incompletePhis)
		addPhiOperands(variable, phi);
	info.sealed = true;
}


void SSACFGBuilder::conditionalJump(
	langutil::DebugData::ConstPtr _debugData,
	InstId _condition,
	SSACFG::BlockId _nonZero,
	SSACFG::BlockId _zero
)
{
	if (m_graph.debugInfo)
		m_graph.debugInfo->setExitDebugData(m_currentBlock, std::move(_debugData));
	currentBlock().exit = SSACFG::BasicBlock::ConditionalJump{
		_condition,
		_nonZero,
		_zero
	};
	m_graph.block(_nonZero).entries.push_back(m_currentBlock);
	m_graph.block(_zero).entries.push_back(m_currentBlock);
	m_currentBlock = {};
}

void SSACFGBuilder::jump(
	langutil::DebugData::ConstPtr _debugData,
	SSACFG::BlockId _target
)
{
	if (m_graph.debugInfo)
		m_graph.debugInfo->setExitDebugData(m_currentBlock, std::move(_debugData));
	currentBlock().exit = SSACFG::BasicBlock::Jump{_target};
	yulAssert(!blockInfo(_target).sealed);
	m_graph.block(_target).entries.push_back(m_currentBlock);
	m_currentBlock = _target;
}

