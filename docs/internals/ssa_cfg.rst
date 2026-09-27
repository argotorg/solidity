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

.. note::

   Not yet written. Planned content:

   - What this page covers.
   - Terminology and notation.

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
