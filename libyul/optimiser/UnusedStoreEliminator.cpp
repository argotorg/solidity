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
 * Optimiser component that removes stores to memory and storage slots that are not used
 * or overwritten later on.
 */

#include <libyul/optimiser/UnusedStoreEliminator.h>

#include <libyul/optimiser/Semantics.h>
#include <libyul/optimiser/OptimizerUtilities.h>
#include <libyul/optimiser/Semantics.h>
#include <libyul/optimiser/ASTWalker.h>
#include <libyul/optimiser/DataFlowAnalyzer.h>
#include <libyul/optimiser/KnowledgeBase.h>
#include <libyul/ControlFlowSideEffectsCollector.h>
#include <libyul/AST.h>
#include <libyul/Utilities.h>

#include <libyul/backends/evm/EVMDialect.h>

#include <libsolutil/CommonData.h>
#include <libsolutil/Visitor.h>

#include <libevmasm/Instruction.h>
#include <libevmasm/SemanticInformation.h>

#include <range/v3/algorithm/all_of.hpp>
#include <range/v3/algorithm/any_of.hpp>

#include <functional>

using namespace solidity;
using namespace solidity::yul;

namespace
{

/// @returns true if @a _expression references the variable @a _variable.
bool references(Expression const& _expression, YulName _variable)
{
	return std::visit(util::GenericVisitor{
		[&](FunctionCall const& _call) {
			return ranges::any_of(_call.arguments, [&](Expression const& _argument) {
				return references(_argument, _variable);
			});
		},
		[&](Identifier const& _identifier) { return _identifier.name == _variable; },
		[](Literal const&) { return false; }
	}, _expression);
}

/// Collects the variables assigned in the statements it visits.
/// Takes the variables assigned in nested blocks from @a _assignedInBlock instead of walking them.
class AssignedVariablesCollector: public ASTWalker
{
public:
	AssignedVariablesCollector(
		std::set<YulName>& _names,
		std::function<std::set<YulName> const&(Block const&)> _assignedInBlock
	):
		m_names(_names),
		m_assignedInBlock(std::move(_assignedInBlock))
	{}

	using ASTWalker::operator();
	void operator()(Assignment const& _assignment) override
	{
		for (Identifier const& variable: _assignment.variableNames)
			m_names.insert(variable.name);
	}
	void operator()(Block const& _block) override { m_names += m_assignedInBlock(_block); }

private:
	std::set<YulName>& m_names;
	std::function<std::set<YulName> const&(Block const&)> m_assignedInBlock;
};

}

void UnusedStoreEliminator::run(OptimiserStepContext& _context, Block& _ast)
{
	std::map<FunctionHandle, SideEffects> functionSideEffects = SideEffectsPropagator::sideEffects(
		_context.dialect,
		CallGraphGenerator::callGraph(_ast)
	);

	bool const ignoreMemory = MSizeFinder::containsMSize(_context.dialect, _ast);
	UnusedStoreEliminator rse{
		_context.dialect,
		functionSideEffects,
		ControlFlowSideEffectsCollector{_context.dialect, _ast}.functionSideEffectsNamed(),
		ignoreMemory
	};
	rse(_ast);

	auto evmDialect = dynamic_cast<EVMDialect const*>(&_context.dialect);
	if (evmDialect && evmDialect->providesObjectAccess())
		rse.clearActive(Location::Memory);
	else
		rse.markActiveAsUsed(Location::Memory);
	rse.markActiveAsUsed(Location::Storage);
	rse.m_storesToRemove += rse.m_allStores - rse.m_usedStores;

	std::set<Statement const*> toRemove{rse.m_storesToRemove.begin(), rse.m_storesToRemove.end()};
	StatementRemover remover{toRemove};
	remover(_ast);
}

UnusedStoreEliminator::UnusedStoreEliminator(
	Dialect const& _dialect,
	std::map<FunctionHandle, SideEffects> const& _functionSideEffects,
	std::map<YulName, ControlFlowSideEffects> _controlFlowSideEffects,
	bool _ignoreMemory
):
	UnusedStoreBase(_dialect),
	m_ignoreMemory(_ignoreMemory),
	m_functionSideEffects(_functionSideEffects),
	m_controlFlowSideEffects(std::move(_controlFlowSideEffects)),
	m_addBuiltinHandle(_dialect.findBuiltin("add")),
	m_subBuiltinHandle(_dialect.findBuiltin("sub")),
	m_knowledgeBase(
		[this](YulName _var) -> AssignedValue const* {
			if (m_currentAssignment && m_currentAssignment->first == _var)
				return &m_currentAssignment->second;
			return nullptr;
		},
		_dialect
	)
{}

void UnusedStoreEliminator::operator()(FunctionCall const& _functionCall)
{
	UnusedStoreBase::operator()(_functionCall);

	for (Operation const& op: operationsFromFunctionCall(_functionCall))
		applyOperation(op);

	ControlFlowSideEffects sideEffects;
	if (auto builtin = resolveBuiltinFunction(_functionCall.functionName, m_dialect))
		sideEffects = builtin->controlFlowSideEffects;
	else
	{
		yulAssert(std::holds_alternative<Identifier>(_functionCall.functionName));
		sideEffects = m_controlFlowSideEffects.at(std::get<Identifier>(_functionCall.functionName).name);
	}

	if (sideEffects.canTerminate)
		markActiveAsUsed(Location::Storage);
	if (!sideEffects.canContinue)
	{
		clearActive(Location::Memory);
		if (!sideEffects.canTerminate)
			clearActive(Location::Storage);
	}
}

void UnusedStoreEliminator::operator()(FunctionDefinition const& _functionDefinition)
{
	for (auto const& parameter: _functionDefinition.parameters)
		handleAssignment({parameter.name}, nullptr);
	for (auto const& returnVariable: _functionDefinition.returnVariables)
		handleAssignment({returnVariable.name}, &m_zero);
	UnusedStoreBase::operator()(_functionDefinition);
}

void UnusedStoreEliminator::operator()(VariableDeclaration const& _variableDeclaration)
{
	UnusedStoreBase::operator()(_variableDeclaration);

	if (_variableDeclaration.value)
		handleAssignment(
			util::applyMap(_variableDeclaration.variables, [](NameWithDebugData const& _var) { return _var.name; }),
			_variableDeclaration.value.get()
		);
	else
		for (auto const& variable: _variableDeclaration.variables)
			handleAssignment({variable.name}, &m_zero);
}

void UnusedStoreEliminator::operator()(Assignment const& _assignment)
{
	UnusedStoreBase::operator()(_assignment);
	handleAssignment(
		util::applyMap(_assignment.variableNames, [](Identifier const& _var) { return _var.name; }),
		_assignment.value.get()
	);
}

void UnusedStoreEliminator::operator()(Block const& _block)
{
	UnusedStoreBase::operator()(_block);
	// Blocks are the bodies of branches, loops and functions. Variables assigned inside might have
	// different values on the paths that join after the block.
	forgetValues(assignedVariables(_block));
}

void UnusedStoreEliminator::operator()(ForLoop const& _forLoop)
{
	// At the loop head, values from the loop entry join with values from the back edge.
	std::set<YulName> assignedInLoop = assignedVariables(_forLoop.body) + assignedVariables(_forLoop.post);
	forgetValues(assignedInLoop);
	UnusedStoreBase::operator()(_forLoop);
	forgetValues(assignedInLoop);
}

void UnusedStoreEliminator::beforeLoopBody(ForLoop const& _forLoop)
{
	// Each visit of the body starts at the loop head, where values from all previous iterations join.
	// Without this, the second visit would relate the locations of stores from the first visit to the
	// current values of the variables, which is only correct if the stored values are read in the very
	// next iteration, but not if they are read in a later one.
	forgetValues(assignedVariables(_forLoop.body) + assignedVariables(_forLoop.post));
}


void UnusedStoreEliminator::operator()(Leave const&)
{
	markActiveAsUsed();
}

void UnusedStoreEliminator::visit(Statement const& _statement)
{
	using evmasm::Instruction;

	UnusedStoreBase::visit(_statement);

	auto const* exprStatement = std::get_if<ExpressionStatement>(&_statement);
	if (!exprStatement)
		return;

	FunctionCall const* funCall = std::get_if<FunctionCall>(&exprStatement->expression);
	yulAssert(funCall);
	std::optional<Instruction> instruction = toEVMInstruction(m_dialect, funCall->functionName);
	if (!instruction)
		return;

	if (!ranges::all_of(funCall->arguments, [](Expression const& _expr) -> bool {
		return std::get_if<Identifier>(&_expr) || std::get_if<Literal>(&_expr);
	}))
		return;

	// We determine if this is a store instruction without additional side-effects
	// both by querying a combination of semantic information and by listing the instructions.
	// This way the assert below should be triggered on any change.
	using evmasm::SemanticInformation;
	bool const writesStorageWithoutOtherSideEffects = (*instruction == Instruction::SSTORE);
	bool const writesMemoryWithoutOtherSideEffects =
		*instruction == Instruction::EXTCODECOPY ||
		*instruction == Instruction::CODECOPY ||
		*instruction == Instruction::CALLDATACOPY ||
		*instruction == Instruction::MSTORE ||
		*instruction == Instruction::MSTORE8 ||
		*instruction == Instruction::MCOPY ||
		*instruction == Instruction::RETURNDATACOPY;
	bool const isBlacklisted =
		// Removing MCOPY is complicated because it's not just a store but also a load.
		*instruction == Instruction::MCOPY ||
		// Trying to optimize out `returndatacopy()` is not worth the extra complexity, because it can rarely be done in the IR we generate.
		// That's because we always immediately ABI-decode the result and only if we can optimize out that decoding, `returndatacopy()` becomes truly unused.
		// Removing it is also hard in a general case because it's not side-effect free - it reverts on out-of-bounds access and we have to preserve that revert.
		// Simple approaches like relying on the size being equal to `returndatasize()` are error-prone, because they have to account for the variable storing the size going stale.
		*instruction == Instruction::RETURNDATACOPY;
	bool const isSemanticCandidateForRemoval =
		SemanticInformation::otherState(*instruction) != SemanticInformation::Write && (
			SemanticInformation::storage(*instruction) == SemanticInformation::Write ||
			(!m_ignoreMemory && SemanticInformation::memory(*instruction) == SemanticInformation::Write)
		);
	yulAssert(isSemanticCandidateForRemoval == (writesStorageWithoutOtherSideEffects || (!m_ignoreMemory && writesMemoryWithoutOtherSideEffects)));
	bool const isCandidateForRemoval = isSemanticCandidateForRemoval && !isBlacklisted;
	if (isCandidateForRemoval)
	{
		m_allStores.insert(&_statement);
		std::vector<Operation> operations = operationsFromFunctionCall(*funCall);
		yulAssert(operations.size() == 1, "");
		ActiveStore store{&_statement, std::move(operations.front())};
		if (store.operation.location == Location::Storage)
			activeStorageStores().insert(std::move(store));
		else
		{
			yulAssert(store.operation.location == Location::Memory, "");
			activeMemoryStores().insert(std::move(store));
		}
	}
}

std::vector<UnusedStoreEliminator::Operation> UnusedStoreEliminator::operationsFromFunctionCall(
	FunctionCall const& _functionCall
)
{
	using evmasm::Instruction;

	SideEffects sideEffects;
	if (BuiltinFunction const* f = resolveBuiltinFunction(_functionCall.functionName, m_dialect))
		sideEffects = f->sideEffects;
	else
	{
		yulAssert(std::holds_alternative<Identifier>(_functionCall.functionName));
		sideEffects = m_functionSideEffects.at(std::get<Identifier>(_functionCall.functionName).name);
	}

	std::optional<Instruction> instruction = toEVMInstruction(m_dialect, _functionCall.functionName);
	if (!instruction)
	{
		std::vector<Operation> result;
		// Unknown read is worse than unknown write.
		if (sideEffects.memory != SideEffects::Effect::None)
			result.emplace_back(Operation{Location::Memory, Effect::Read, {}, {}});
		if (sideEffects.storage != SideEffects::Effect::None)
			result.emplace_back(Operation{Location::Storage, Effect::Read, {}, {}});
		return result;
	}

	using evmasm::SemanticInformation;

	return util::applyMap(
		SemanticInformation::readWriteOperations(*instruction),
		[&](SemanticInformation::Operation const& _op) -> Operation
		{
			yulAssert(!(_op.lengthParameter && _op.lengthConstant));
			yulAssert(_op.effect != Effect::None);
			Operation ourOp{_op.location, _op.effect, {}, {}};
			if (_op.startParameter)
				ourOp.start = m_knowledgeBase.explore(_functionCall.arguments.at(*_op.startParameter));
			if (_op.lengthParameter)
				ourOp.length = m_knowledgeBase.explore(_functionCall.arguments.at(*_op.lengthParameter));
			if (_op.lengthConstant)
				switch (*_op.lengthConstant)
				{
				case 1: ourOp.length = KnowledgeBase::VariableOffset{{}, u256(1)}; break;
				case 32: ourOp.length = KnowledgeBase::VariableOffset{{}, u256(32)}; break;
				default: yulAssert(false);
				}
			return ourOp;
		}
	);
}

void UnusedStoreEliminator::applyOperation(UnusedStoreEliminator::Operation const& _operation)
{
	std::set<ActiveStore>& active =
		_operation.location == Location::Storage ?
		activeStorageStores() :
		activeMemoryStores();

	for (auto it = active.begin(); it != active.end();)
	{
		if (_operation.effect == Effect::Read && !knownUnrelated(it->operation, _operation))
		{
			// This store is read from, mark it as used and remove it from the active set.
			m_usedStores.insert(it->statement);
			it = active.erase(it);
		}
		else if (_operation.effect == Effect::Write && knownCovered(it->operation, _operation))
			// This store is overwritten before being read, remove it from the active set.
			it = active.erase(it);
		else
			++it;
	}
}

bool UnusedStoreEliminator::knownUnrelated(
	UnusedStoreEliminator::Operation const& _op1,
	UnusedStoreEliminator::Operation const& _op2
) const
{
	if (_op1.location != _op2.location)
		return true;
	if (_op1.location == Location::Storage)
	{
		if (_op1.start && _op2.start)
		{
			yulAssert(
				_op1.length &&
				_op2.length &&
				lengthValue(*_op1.length) == 1 &&
				lengthValue(*_op2.length) == 1
			);
			return KnowledgeBase::knownToBeDifferent(*_op1.start, *_op2.start);
		}
	}
	else
	{
		yulAssert(_op1.location == Location::Memory, "");
		if (
			(_op1.length && lengthValue(*_op1.length) == 0) ||
			(_op2.length && lengthValue(*_op2.length) == 0)
		)
			return true;

		if (_op1.start && _op1.length && _op2.start)
		{
			std::optional<u256> length1 = lengthValue(*_op1.length);
			std::optional<u256> start1 = _op1.start->absoluteValue();
			std::optional<u256> start2 = _op2.start->absoluteValue();
			if (
				(length1 && start1 && start2) &&
				*start1 + *length1 >= *start1 && // no overflow
				*start1 + *length1 <= *start2
			)
				return true;
		}
		if (_op2.start && _op2.length && _op1.start)
		{
			std::optional<u256> length2 = lengthValue(*_op2.length);
			std::optional<u256> start2 = _op2.start->absoluteValue();
			std::optional<u256> start1 = _op1.start->absoluteValue();
			if (
				(length2 && start2 && start1) &&
				*start2 + *length2 >= *start2 && // no overflow
				*start2 + *length2 <= *start1
			)
				return true;
		}

		if (_op1.start && _op1.length && _op2.start && _op2.length)
		{
			std::optional<u256> length1 = lengthValue(*_op1.length);
			std::optional<u256> length2 = lengthValue(*_op2.length);
			if (
				(length1 && *length1 <= 32) &&
				(length2 && *length2 <= 32) &&
				KnowledgeBase::knownToBeDifferentByAtLeast32(*_op1.start, *_op2.start)
			)
				return true;
		}
	}

	return false;
}

bool UnusedStoreEliminator::knownCovered(
	UnusedStoreEliminator::Operation const& _covered,
	UnusedStoreEliminator::Operation const& _covering
) const
{
	if (_covered.location != _covering.location)
		return false;
	if (
		(_covered.start && _covered.start == _covering.start) &&
		(_covered.length && _covered.length == _covering.length)
	)
		return true;
	if (_covered.location == Location::Memory)
	{
		if (_covered.length && lengthValue(*_covered.length) == 0)
			return true;

		// Condition (i = cover_i_ng, e = cover_e_d):
		// i.start <= e.start && e.start + e.length <= i.start + i.length
		if (!_covered.start || !_covering.start || !_covered.length || !_covering.length)
			return false;
		std::optional<u256> coveredLength = lengthValue(*_covered.length);
		std::optional<u256> coveringLength = lengthValue(*_covering.length);
		if (*_covered.start == *_covering.start)
			if (coveredLength && coveringLength && *coveredLength <= *coveringLength)
				return true;
		std::optional<u256> coveredStart = _covered.start->absoluteValue();
		std::optional<u256> coveringStart = _covering.start->absoluteValue();
		if (coveredStart && coveringStart && coveredLength && coveringLength)
			if (
				*coveringStart <= *coveredStart &&
				*coveringStart + *coveringLength >= *coveringStart && // no overflow
				*coveredStart + *coveredLength >= *coveredStart && // no overflow
				*coveredStart + *coveredLength <= *coveringStart + *coveringLength
			)
				return true;

		// TODO for this we probably need a non-overflow assumption as above.
		// Condition (i = cover_i_ng, e = cover_e_d):
		// i.start <= e.start && e.start + e.length <= i.start + i.length
	}
	return false;
}

void UnusedStoreEliminator::markActiveAsUsed(
	std::optional<UnusedStoreEliminator::Location> _onlyLocation
)
{
	if (_onlyLocation == std::nullopt || _onlyLocation == Location::Memory)
		for (ActiveStore const& store: activeMemoryStores())
			m_usedStores.insert(store.statement);
	if (_onlyLocation == std::nullopt || _onlyLocation == Location::Storage)
		for (ActiveStore const& store: activeStorageStores())
			m_usedStores.insert(store.statement);
	clearActive(_onlyLocation);
}

void UnusedStoreEliminator::clearActive(
	std::optional<UnusedStoreEliminator::Location> _onlyLocation
)
{
	if (_onlyLocation == std::nullopt || _onlyLocation == Location::Memory)
		activeMemoryStores() = {};
	if (_onlyLocation == std::nullopt || _onlyLocation == Location::Storage)
		activeStorageStores() = {};
}

void UnusedStoreEliminator::handleAssignment(std::vector<YulName> const& _variables, Expression const* _value)
{
	for (YulName const& variable: _variables)
		m_knowledgeBase.variableChanged(variable);
	if (
		_value &&
		_variables.size() == 1 &&
		mayBeOffset(*_value) &&
		!references(*_value, _variables.front())
	)
	{
		// For `x := add(y, 32)`, the value of `x` must use the version of `y` from this assignment,
		// not from the later point where `x` is used in a store or load. So we let the knowledge base
		// evaluate and cache it right here.
		// The value is only visible to the knowledge base during this call.
		m_currentAssignment = {_variables.front(), AssignedValue{_value, 0}};
		m_knowledgeBase.explore(_variables.front());
		m_currentAssignment.reset();
	}
}

bool UnusedStoreEliminator::mayBeOffset(Expression const& _value) const
{
	FunctionCall const* call = std::get_if<FunctionCall>(&_value);
	if (!call)
		return true;
	if (!isBuiltinFunctionCall(*call))
		return false;
	BuiltinHandle const& handle = std::get<BuiltinName>(call->functionName).handle;
	return handle == m_addBuiltinHandle || handle == m_subBuiltinHandle;
}

std::set<YulName> const& UnusedStoreEliminator::assignedVariables(Block const& _block)
{
	if (auto it = m_assignedVariables.find(&_block); it != m_assignedVariables.end())
		return it->second;

	std::set<YulName> names;
	AssignedVariablesCollector collector{names, [this](Block const& _nested) -> std::set<YulName> const& {
		return assignedVariables(_nested);
	}};
	for (Statement const& statement: _block.statements)
		collector.visit(statement);
	return m_assignedVariables[&_block] = std::move(names);
}

void UnusedStoreEliminator::forgetValues(std::set<YulName> const& _variables)
{
	for (YulName const& variable: _variables)
		m_knowledgeBase.variableChanged(variable);
}
