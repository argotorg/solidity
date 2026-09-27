:orphan:

.. index:: ! SSA CFG, ! Pizlo form, ! phi, ! upsilon

.. _ssa-cfg:

***************
SSA CFG Backend
***************

.. warning::

   The SSA CFG backend is experimental.
   It may change without notice.

.. note::

   This page is a working draft and is deliberately kept out of the documentation TOC.
   It is written for compiler developers, not for users of the compiler.

.. contents::
   :local:
   :depth: 1

.. _ssa-cfg-status:

Status and Scope
================

This page specifies the SSA CFG backend.

Terminology
-----------

Several terms mean different things in the compiler at large, in the code of this backend, and on this page.

Block
   A basic block of the SSA CFG.
   A braced block of Yul code is a *Yul block*.

Function graph
   One SSA CFG, ``SSACFG`` in the code.
   The code of a Yul object is represented by one *main graph* for its top-level statements
   and one function graph per Yul function definition.

Value
   An SSA value, the result of an ``Inst``.
   Every Inst has an ``InstId``, but not every Inst has exactly one result:

   - An Inst with one result is identified with it, and its ``InstId`` names both.
   - An operation with two or more results is not a value itself.
     Each of its results is a ``Projection`` Inst that directly follows it.
   - Operations without results, such as ``sstore`` or a call of a function without return variables,
     as well as upsilons and ``Nop`` placeholders, produce no value.

   Nothing in the types tells an ``InstId`` that names a value from one that does not.
   Apart from a projection, which refers to its operation, every input of an Inst is an Inst with one result.
   The builder relies on the Yul analysis for this, which admits only calls with exactly one result as arguments.

   Yul variables do not exist in the IR; they exist only during construction.

Inst and operation
   An *Inst* is an instruction of the IR.
   An *operation* is an Inst that emits code:
   a call of a Yul function, a call of a builtin, or ``memoryguard`` (``Inst::isOperation``).
   An instruction of the EVM is an *opcode*.

Exit
   The terminator of a block (``BasicBlock::exit``):
   an unconditional jump, a conditional jump, a function return, the end of the main graph, or termination.

Edge
   A pair of blocks :math:`(P, S)` such that the exit of :math:`P` can transfer control to :math:`S`.
   A conditional jump has a *nonZero edge* and a *zero edge*, named after the condition values that select them.

Stack
   The *EVM stack* exists at runtime.
   The *symbolic stack* (``StackData``) is its model at compile time, a sequence of symbolic stack slots.

Layout
   Always a stack layout on this page, never a storage, memory, or calldata layout as in other internals pages.

Spill
   Moving a value from the stack into a memory slot and reloading it from there when needed.
   The backend spills on its own; it does not use the ``StackLimitEvader`` of the Yul optimizer.

Shadow
   In Pizlo form, the location that the upsilons of a phi write and that the phi reads (see :ref:`ssa-cfg-ir`).
   On ``develop``, shadows are a device of the semantics only; the stack layout gives them no slot of their own.

Trace
   A recorded sequence of stack operations (``ShuffleTrace``).

Junk
   A stack slot whose contents do not matter. Sometimes also referred to as *wildcard slot*. (TODO: unify)

Notation
--------

IR listings use the syntax of the IR printer, as seen in the tests under ``test/libyul/ssa/printer``:

.. code-block:: none

   #1: preds: #0, #2
       v2 = phi
       v3 = builtin @lt v2, v1
       branch v3, #2, #4
   #2: preds: #1
       v7 = builtin @add v2, v6
       upsilon v7 -> ^v2
       jump #1

- ``vN`` is the Inst with ``InstId`` N, and also its value if it has exactly one result.
  ``#N`` is the block with ``BlockId`` N.
- The printer writes ``vN =`` in front of every Inst with results,
  including an operation whose results are projections (``v0 = call @pair`` followed by ``v1 = proj v0, 0``).
  It leaves it out for operations without results and for upsilons.
- ``^vN`` is the shadow of the phi ``vN``, so ``upsilon v7 -> ^v2`` writes ``v7`` into the shadow of ``v2``.
- ``branch c, #a, #b`` is a conditional jump on ``c`` with nonZero target ``#a`` and zero target ``#b``.
- Stacks are written from bottom to top, with the top at the right.
  In stacks, a literal value prints as ``litN`` and a phi as ``phiN``, where N is the ``InstId``.

.. _ssa-cfg-pipeline:

Pipeline as Data Flow
=====================

.. note::

   Not yet written. Planned content:

   - How the backend is enabled.
   - The stages, what each produces, and at which granularity each runs.

.. _ssa-cfg-ir:

The IR: SSA CFG in Pizlo Form
=============================

.. note::

   Not yet written. Planned content:

   - Data model: ``ControlFlowGraphs`` and its ``memoryguard`` value, function graphs, basic blocks and their exits,
     ``Inst`` and its opcodes, projections of multi-return operations, deduplicated literals,
     the ``Identity``, ``Nop`` and ``Tombstone`` placeholders.
   - Pizlo form: phi, upsilon, and shadow; snapshot semantics; comparison with phis that carry operand lists.
   - Validity: every path to a phi passes an upsilon for it; what is deliberately not required.
   - What the builder produces today, and which of these shapes are guarantees and which are accidents.
   - Which of these properties hold before and which after the transforms.

.. _ssa-cfg-construction:

Construction from Yul
=====================

.. note::

   Not yet written. Planned content:

   - Input requirements and the relation to the Yul optimizer.
   - SSA construction after Braun et al., block sealing, and the documented deviation in Algorithms 2 and 4.
   - Lowering of ``if``, ``switch``, ``for``, ``break``, ``continue``, ``leave``, and function definitions.
   - Builtins with literal arguments, multi-return operations, ``memoryguard``.
   - Continuation: which functions can return to their caller.

.. _ssa-cfg-transforms:

Transforms
==========

.. note::

   Not yet written. Planned content:

   - The pass contract: what a pass may assume, what it must preserve, and the effects model for phis and upsilons.
   - The current pipeline and what it guarantees for its output.
   - Per pass, including its obligations towards phis and upsilons:
     constant condition folding, unreachable block cleanup, trivial phi elimination, identity and nop removal,
     jump threading, and the inactive outliner.
   - Planned passes and what they would do to phis and upsilons.

.. _ssa-cfg-backend-contract:

Backend Contract
================

.. note::

   Not yet written. Planned content:

   - What the backend requires of its input graphs, why,
     and what happens when a requirement is not met.
   - The graphs must not change once the liveness analysis has run.
   - The nonZero-edge hazard as its own item.

.. _ssa-cfg-analyses:

Analyses
========

.. note::

   Not yet written. Planned content:

   - Forward topological order, back edges, and reducibility.
   - The loop nesting forest.
   - Liveness with use counts, and how phis and upsilons enter it.
   - Call graph and recursion.
   - Blocks that admit junk, via bridge finding.
   - Phi inverse.

.. _ssa-cfg-stack-model:

Stack Model
===========

.. note::

   Not yet written. Planned content:

   - Stack slots: values, literals, junk, function return labels, call return labels; slots that can be generated freely.
   - The reachable stack depth and what "stack too deep" means in this backend.
   - Shuffle operations and traces.
   - Block layouts: stack-in, operation traces, exit trace, edge traces.

.. _ssa-cfg-layout:

Stack Layout Generation
=======================

.. note::

   Not yet written. Planned content:

   - Contract: what a layout must satisfy for emission to be a pure replay.
   - Current algorithm: traversal order, stack-in selection at joins, operation stack-in, the shuffler, back edges, exits.

.. _ssa-cfg-spilling:

Spilling
========

.. note::

   Not yet written. Planned content:

   - Why static spill slots are sound, and how this differs from the ``StackLimitEvader``.
   - The spill fixpoint, the reachability closure, and def-site store traces.
   - When the memory of a spilled value is valid.
   - Memory addressing and the ``memoryguard`` bump.

.. _ssa-cfg-emission:

Emission to EVM Assembly
========================

.. note::

   Not yet written. Planned content:

   - Calling convention: argument order, call return labels, the function return label.
   - Block order, labels, and exits.
   - Emission as a pure replay of recorded traces, and the symbolic checks along the way.
   - Spill loads and stores.

.. _ssa-cfg-design-space:

Design Space for Phi/Upsilon Realization
========================================

.. note::

   Not yet written. Planned content:

   - Two axes, kept apart: representation (edge copies per predecessor, shadow slots)
     and realization point (at the phi's position, on the edge, at the block exit).
   - For each design that was tried: what it assumes from the IR, what it satisfies from the backend contract,
     what it cost, and why it was left. Branch names serve as pointers, not as the subject.
   - The facts that decide most of it.

.. _ssa-cfg-testing:

Testing, Tooling, and Evidence
==============================

.. note::

   Not yet written. Planned content:

   - The isoltest suites under ``test/libyul/ssa`` and what each pins down; semantic tests through this backend.
   - Output formats: printer, Graphviz export, ``yulCFGJson``.
   - Measurements, each with baseline and binary named, marked as recorded or re-run.
   - Bugs found so far and how each was found.

.. _ssa-cfg-glossary:

Appendix: Glossary
==================

.. note::

   Not yet written.

.. _ssa-cfg-references:

Appendix: References
====================

.. note::

   Not yet written. References are added as the chapters citing them are written.
