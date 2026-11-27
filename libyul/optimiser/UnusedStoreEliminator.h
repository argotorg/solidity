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

#pragma once

#include <libyul/ASTForward.h>
#include <libyul/optimiser/ASTWalker.h>
#include <libyul/optimiser/OptimiserStep.h>
#include <libyul/optimiser/Semantics.h>
#include <libyul/optimiser/UnusedStoreBase.h>
#include <libyul/optimiser/KnowledgeBase.h>
#include <libyul/optimiser/DataFlowAnalyzer.h>
#include <libyul/AST.h>

#include <libevmasm/SemanticInformation.h>

#include <map>
#include <optional>
#include <tuple>
#include <unordered_map>
#include <utility>
#include <vector>

namespace solidity::yul
{
class Dialect;
struct AssignedValue;

/**
 * UnusedStoreEliminator is an optimizer component that removes sstore and memory store statements if conditions are met
 * for their removal.
 * In case of an sstore, if all outgoing code paths revert (due to an explicit revert(), invalid(),
 * or infinite recursion) or lead to another ``sstore`` for which the optimizer can tell that it will overwrite the first store,
 * the statement will be removed.
 *
 * For memory store operations, things are generally simpler, at least in the outermost yul block as all such statements
 * will be removed if they are never read from in any code path. At function analysis level however, the approach is similar
 * to sstore, as we don't know whether the memory location will be read once we leave the function's scope,
 * so the statement will be removed only if all code code paths lead to a memory overwrite.
 *
 * To decide whether two operations can touch the same location, the step keeps track of the values of variables
 * while it walks the code. Each location is recorded as a constant offset from the value a variable had at that
 * point in the code. For example, in `let q := add(p, 32) mstore(q, 1)` the location of the store is recorded
 * as 32 more than the value `p` had when the store was executed. When a variable is reassigned, it is treated
 * as a new variable, so a location recorded earlier keeps referring to the old value. This is what allows a store
 * to be compared correctly with reads and writes that happen later, after some of the variables have changed.
 * Where control flow joins, the values of variables assigned inside a branch or loop are forgotten.
 *
 * A store whose result might still be read is remembered together with the location it wrote to. A store inside
 * a loop can write to a different location in each iteration, as `mstore(p, 1)` does in a loop body like
 * `let p := sload(0) mstore(p, 1) sstore(0, add(p, 32))`. Loop bodies are walked twice, so such a store is
 * remembered twice, once with the location from each walk. The store is only removed if neither of these
 * locations is read later. Each walk starts by forgetting the values of the variables assigned in the loop,
 * because a store might be read any number of iterations later. Without that, the second walk would treat
 * a location from the first walk as if it was always read in the very next iteration.
 *
 * Works best in SSA form, but does not require it.
 *
 * Prerequisite: Disambiguator, ForLoopInitRewriter.
 */

/// Memory or storage operation, with its location as a snapshot taken when the operation was executed.
struct UnusedStoreEliminatorOperation
{
	evmasm::SemanticInformation::Location location;
	evmasm::SemanticInformation::Effect effect;
	/// Start of affected area. Unknown if not provided.
	std::optional<KnowledgeBase::VariableOffset> start;
	/// Length of affected area. Unknown if not provided. Unused for storage.
	std::optional<KnowledgeBase::VariableOffset> length;
};

/// One execution of a store statement that is active in UnusedStoreEliminator.
/// Executions of the same statement at different locations (e.g. in different iterations of a loop)
/// are different active stores.
struct UnusedStoreEliminatorActiveStore
{
	Statement const* statement;
	UnusedStoreEliminatorOperation operation;

	bool operator<(UnusedStoreEliminatorActiveStore const& _other) const
	{
		return
			std::tie(statement, operation.location, operation.effect, operation.start, operation.length) <
			std::tie(
				_other.statement,
				_other.operation.location,
				_other.operation.effect,
				_other.operation.start,
				_other.operation.length
			);
	}
};

extern template class UnusedStoreBase<UnusedStoreEliminatorKey, UnusedStoreEliminatorActiveStore>;

class UnusedStoreEliminator: public UnusedStoreBase<UnusedStoreEliminatorKey, UnusedStoreEliminatorActiveStore>
{
public:
	static constexpr char const* name{"UnusedStoreEliminator"};
	static void run(OptimiserStepContext& _context, Block& _ast);

	explicit UnusedStoreEliminator(
		Dialect const& _dialect,
		std::map<FunctionHandle, SideEffects> const& _functionSideEffects,
		std::map<YulName, ControlFlowSideEffects> _controlFlowSideEffects,
		bool _ignoreMemory
	);

	using UnusedStoreBase::operator();
	void operator()(FunctionCall const& _functionCall) override;
	void operator()(FunctionDefinition const&) override;
	void operator()(Leave const&) override;
	void operator()(VariableDeclaration const& _variableDeclaration) override;
	void operator()(Assignment const& _assignment) override;
	void operator()(Block const& _block) override;
	void operator()(ForLoop const& _forLoop) override;

	using UnusedStoreBase::visit;
	void visit(Statement const& _statement) override;

	using Location = evmasm::SemanticInformation::Location;
	using Effect = evmasm::SemanticInformation::Effect;
	using Operation = UnusedStoreEliminatorOperation;
	using ActiveStore = UnusedStoreEliminatorActiveStore;

private:
	std::set<ActiveStore>& activeMemoryStores() { return m_activeStores[UnusedStoreEliminatorKey::Memory]; }
	std::set<ActiveStore>& activeStorageStores() { return m_activeStores[UnusedStoreEliminatorKey::Storage]; }
	static std::optional<u256> lengthValue(KnowledgeBase::VariableOffset const& _length) { return _length.absoluteValue(); }

	void shortcutNestedLoop(ActiveStores const&) override
	{
		// We might only need to do this for newly introduced stores in the loop.
		markActiveAsUsed();
	}
	void finalizeFunctionDefinition(FunctionDefinition const&) override
	{
		markActiveAsUsed();
	}
	void beforeLoopBody(ForLoop const& _forLoop) override;

	std::vector<Operation> operationsFromFunctionCall(FunctionCall const& _functionCall);
	void applyOperation(Operation const& _operation);
	bool knownUnrelated(Operation const& _op1, Operation const& _op2) const;
	bool knownCovered(Operation const& _covered, Operation const& _covering) const;

	void markActiveAsUsed(std::optional<Location> _onlyLocation = std::nullopt);
	void clearActive(std::optional<Location> _onlyLocation = std::nullopt);

	/// Records the assignment of @a _value (nullptr if unknown) to @a _variables.
	/// The variables get unknown values if several are assigned at once (e.g. `a, b := f()`) or if @a _value
	/// references the assigned variable (e.g. `x := add(x, 1)`).
	/// @a _isDeclaration is true for variable declarations and function parameters and return variables.
	void handleAssignment(std::vector<YulName> const& _variables, Expression const* _value, bool _isDeclaration);
	/// @returns false if @a _value is certainly not a constant offset from a variable or a constant,
	/// i.e. if it is a call other than `add` or `sub`. Such a value does not have to be evaluated
	/// at the assignment, as the knowledge base treats the variable as unknown anyway.
	bool mayBeOffset(Expression const& _value) const;
	/// Forgets the values of the given variables by giving them new versions in the knowledge base.
	/// Used where control flow joins and the variables might have different values on different paths.
	void forgetValues(std::set<YulName> const& _variables);
	/// @returns the variables assigned anywhere inside @a _block, including nested blocks.
	/// The result is cached, as blocks are visited repeatedly (loop bodies twice, nested blocks once per enclosing block).
	std::set<YulName> const& assignedVariables(Block const& _block);

	bool const m_ignoreMemory;
	std::map<FunctionHandle, SideEffects> const& m_functionSideEffects;
	std::map<YulName, ControlFlowSideEffects> m_controlFlowSideEffects;
	std::optional<BuiltinHandle> m_addBuiltinHandle;
	std::optional<BuiltinHandle> m_subBuiltinHandle;

	/// The assignment handleAssignment is processing. It provides the only value the knowledge base can see.
	std::optional<std::pair<YulName, AssignedValue>> m_currentAssignment;
	/// Special expression whose address is used as the value of variables declared without a value.
	Expression const m_zero{Literal{{}, LiteralKind::Number, LiteralValue{0, std::nullopt}}};

	KnowledgeBase m_knowledgeBase;

	/// Number of loops the current statement is in. Unlike UnusedStoreBase::m_forLoopNestingDepth,
	/// it is not reset in function definitions, as a function defined in a loop is also visited repeatedly.
	size_t m_loopDepth = 0;

	/// Cache for assignedVariables.
	std::unordered_map<Block const*, std::set<YulName>> m_assignedVariables;
};

}
