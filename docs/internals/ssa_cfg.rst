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

This chapter follows the data from Yul to EVM assembly:
which stage produces what, and at which granularity.

Enabling the Backend
--------------------

On the command line, the backend is enabled by ``--via-ssa-cfg``, which requires ``--experimental`` and implies ``--via-ir``.
The option applies to Solidity input and to Yul input in assembler mode.
In Standard JSON, it is enabled by ``settings.viaSSACFG``, which requires ``settings.experimental``.
It sets ``settings.viaIR`` and is rejected if ``settings.viaIR`` is explicitly ``false``.
The contract metadata records ``settings.viaSSACFG``.

Stages and Artifacts
--------------------

.. graphviz::
   :caption: Data flow for one Yul object. Boxes are stages, edge labels name the artifacts handed over.
             The dashed frame groups the stages that ``CodeTransform::run`` performs.
   :align: center

   digraph ssa_cfg_pipeline {
       graph [fontname="Helvetica", fontsize=10, nodesep=0.5, ranksep=0.4];
       node [shape=box, style=rounded, fontname="Helvetica", fontsize=10];
       edge [fontname="Helvetica", fontsize=9];

       yul [label="Yul object\n(syntax tree, AsmAnalysisInfo)", shape=note, style=""];
       build [label="Construction\nSSACFGBuilder::build\nper object"];
       transforms [label="Transforms\ntransform::optimize\nper function graph"];
       liveness [label="Liveness\nLivenessAnalysis\nper function graph"];
       evmasm [label="evmasm\noptimize and assemble", style="rounded,dashed"];

       subgraph cluster_run {
           label="CodeTransform::run";
           style=dashed;
           calls [label="Call structure\nCallGraph, gatherCallSites"];
           layout [label="Stack layout and spilling\nStackLayoutGenerator::generate\nper function graph"];
           addressing [label="Memory addressing\nspill::MemoryAddressing\nper object"];
           emission [label="Emission\nCodeTransform\nper function graph"];
       }

       yul -> build;
       build -> transforms [label=" graphs (built)"];
       transforms -> liveness [label=" graphs (transformed)"];
       transforms -> calls [label=" graphs"];
       liveness -> layout [label=" liveness,\n traversal order"];
       calls -> layout [label=" call sites,\n may spill"];
       layout -> addressing [label=" spill sets"];
       layout -> emission [label=" layouts,\n store traces"];
       addressing -> emission [label=" addresses,\n memoryguard value"];
       emission -> evmasm [label=" assembly"];
   }

.. list-table::
   :header-rows: 1
   :widths: 20 25 12 43

   * - Stage
     - Code
     - Runs per
     - Produces
   * - Construction
     - ``SSACFGBuilder::build``
     - object
     - ``ControlFlowGraphs``: the main graph, one function graph per Yul function definition,
       and the ``memoryguard`` value of the object, if any.
   * - Transforms
     - ``transform::optimize``
     - function graph
     - The same graphs, changed in place.
   * - Liveness
     - ``ControlFlowGraphsLiveness``
     - function graph
     - A ``LivenessAnalysis``: the forward topological order with its back edges, the loop nesting forest,
       live-in and live-out sets with use counts per block, and live-out sets per operation.
   * - Call structure
     - ``CallGraph``, ``gatherCallSites``
     - object, function graph
     - Whether a function graph lies on a cycle of the call graph,
       and a numbering of the call sites of each function graph, used for return labels.
   * - Stack layout and spilling
     - ``StackLayoutGenerator::generate``
     - function graph
     - An ``SSACFGStackLayout`` (per block: the stack-in, one trace per Inst, the exit trace, and one trace per incoming edge),
       the ``SpillSet``, and the ``SpillStoreTraces``.
   * - Memory addressing
     - ``spill::MemoryAddressing``
     - object
     - A memory address for every spilled value, and the increased ``memoryguard`` value.
   * - Emission
     - ``CodeTransform``
     - function graph
     - Assembly items, appended through ``AbstractAssembly`` to an ``evmasm::Assembly``.

.. _ssa-cfg-ir:

The IR: SSA CFG in Pizlo Form
=============================

The backend works on control flow graphs whose Insts are in static single assignment form:
every value is defined by exactly one Inst, and every use of a value is dominated by its definition.
Where values merge at joins of control flow, the IR does not use phis with operand lists.
It uses the Phi/Upsilon form that Filip Pizlo describes [Pizlo25a]_ [Pizlo25b]_ and that WebKit's B3 compiler uses [B3IR]_,
also called *Pizlo form*.

Data Model
----------

Graphs
~~~~~~

The code of a Yul object becomes one ``ControlFlowGraphs``.
It holds one function graph (``SSACFG``) per Yul function definition and the main graph for the top-level code,
indexed by ``FunctionGraphID``, with the main graph at index 0.
It also holds the ``memoryguard`` value of the object, if the code calls ``memoryguard``.
The value lives here rather than in an Inst because all calls in the object share it,
and because memory addressing raises it once the spill region has been sized (see :ref:`ssa-cfg-spilling`).
Every ``MemoryGuard`` Inst emits the value as it stands at that point.
The builder asserts that all ``memoryguard`` calls of an object have the same argument.

A function graph has an entry block, its parameters as ``FunctionArg`` Insts in order, its number of return values,
and whether it can continue, that is, whether some path returns to the caller.
The builder takes the latter from the control flow side effects of the Yul function.
A call of a function that cannot continue ends its block, and needs no return label.
Each graph owns its blocks and its Insts; ``BlockId`` and ``InstId`` are indices local to the graph.
The graph also carries a set ``exits``, which the builder fills only in part and which no stage reads.

Blocks
~~~~~~

A block has a list of predecessors (``entries``), a list of Insts in execution order (``instructions``), and an exit:

``Jump``
   Continue at the target.

``ConditionalJump``
   Continue at the nonZero target if the condition value is not zero, and at the zero target otherwise.

``FunctionReturn``
   Return the listed values to the caller. Only in function graphs.

``MainExit``
   End of the code of the main graph.

``Terminated``
   Control does not leave the block: it ends in a builtin that terminates or reverts, or in a call that cannot continue.

Successors follow from the exit, while predecessors are stored separately.
The two have to agree, and every piece of code that changes an exit updates the predecessor lists of the affected
blocks by hand. Nothing checks that they agree.
There is one exception: a predecessor list may name a block that can no longer be reached from the entry,
until :ref:`unreachable block cleanup <ssa-cfg-unreachable-block-cleanup>` removes that block.

Insts
~~~~~

Every Inst has an opcode, the block it belongs to, a list of inputs, and a payload that depends on the opcode.

.. list-table::
   :header-rows: 1
   :widths: 16 54 16 14

   * - Opcode
     - Meaning
     - Scheduled in
     - Results
   * - ``Const``
     - A literal. There is one per value and graph.
     - the entry block
     - one
   * - ``FunctionArg``
     - A parameter of the function.
     - the entry block
     - one
   * - ``Phi``
     - Reads its shadow (see below).
     - any block
     - one
   * - ``Upsilon``
     - Writes its input into the shadow of its phi.
     - any block
     - none
   * - ``BuiltinCall``
     - Calls a builtin of the EVM dialect.
       Literal arguments, such as the name in ``datasize``, are part of the payload, not inputs.
     - any block
     - none, one, or projections
   * - ``Call``
     - Calls a function graph.
     - any block
     - none, one, or projections
   * - ``MemoryGuard``
     - ``memoryguard``. Emits the value of the object.
     - any block
     - one
   * - ``Projection``
     - One result of an operation with two or more results.
     - right after the operation
     - one
   * - ``Unreachable``
     - Stands for a value on a path that cannot execute, such as the result of a call that cannot continue.
     - no block
     - one
   * - ``Identity``
     - Forwards its input. Left behind by replacement in place.
     - any block, until removed
     - one
   * - ``Nop``
     - Takes the place of a removed Inst without results.
     - any block, until removed
     - none
   * - ``Tombstone``
     - A free slot of the instruction store.
     - never
     - none

A literal becomes a ``Const`` the first time it is read, and every further use of the same value in the graph refers to
that Inst. Constants belong to the entry block, which dominates every use.
Where a ``Const`` sits in the entry block does not matter:
the backend never keeps a literal alive or spills it, but pushes its value wherever it is needed.

An operation with two or more results is followed directly by its projections, one per result,
both in the instruction store and in its block.
The functions that create such an operation allocate it together with its projections as one contiguous run,
so the API cannot get this wrong, and ``projectionsOf`` asserts it where it relies on it.

Replacement in Place
~~~~~~~~~~~~~~~~~~~~

The IR keeps no use lists.
To replace every use of an Inst, a pass turns the Inst into an ``Identity`` of its replacement, in place.
To remove an Inst without results, a pass turns it into a ``Nop``.
The identity and nop remover later redirects every input through chains of identities,
drops identities and nops from their blocks, and frees their slots.
This follows Pizlo [Pizlo25b]_: without use lists the IR stays small and passes stay simple,
and replacing all uses of an Inst costs one clean-up pass.

The replacement functions assert that neither a ``MemoryGuard`` nor an operation with projections is replaced,
since the projections refer to their operation.
A ``Const`` may become a ``Nop`` but not an ``Identity``, since all uses of its value share it.

A freed slot of the instruction store becomes a ``Tombstone`` and is reused by later allocations,
and the identifiers of freed blocks are reused as well.
An identifier that a pass holds across such a reuse names a different Inst or block afterwards.

Pizlo Form
----------

Semantics
~~~~~~~~~

Every phi has, besides its value, a *shadow*: a location that only upsilons write and only the phi reads.
``upsilon v -> ^p`` stores ``v`` into the shadow of ``p``, and ``p = phi`` loads the shadow of ``p``.
A phi has no inputs.
An upsilon has one input, the value it stores; the phi it writes to is part of its payload and is not a use of the phi.

Phis and upsilons take effect at their position in their block, like any other Inst.
In particular, a phi reads its shadow when it executes, and its value is fixed from then on.
An upsilon that writes the shadow later in the same block does not change it,
as B3 points out where it lowers phis [B3LowerToAir]_:

.. code-block:: none

   p = phi
   upsilon v -> ^p
   ... use of p ...    // the value before the upsilon, not v

Conversely, an upsilon ahead of its phi in the same block determines the phi's value, whichever edge entered the block.

Shadows are not SSA values.
Several upsilons write the same shadow, typically one per incoming path, and each of them may execute any number of times.
But each shadow has exactly one reader, its phi, which is why Pizlo calls the shadows static single use.

The following graph comes from ``let x := calldataload(3) if mload(42) { x := calldataload(77) } sstore(0, x)``:

.. code-block:: none

   #0:
       v0 = const 0x03
       v1 = builtin @calldataload v0
       v2 = const 0x2a
       v3 = builtin @mload v2
       v4 = const 0x4d
       upsilon v1 -> ^v6
       v9 = const 0x00
       branch v3, #1, #2
   #1: preds: #0
       v5 = builtin @calldataload v4
       upsilon v5 -> ^v6
       jump #2
   #2: preds: #0, #1
       v6 = phi
       builtin @sstore v9, v6
       main_exit

Block ``#0`` writes the old value of ``x`` into the shadow of ``v6`` before it branches.
On the path through ``#1``, that value is overwritten with ``v5``.
On the direct path, the phi reads ``v1``.

Why Pizlo Form
~~~~~~~~~~~~~~

A phi with an operand list has one operand per predecessor of its block,
and the operands have to stay in step with the predecessors.
Every change to the edges of a block, such as removing, redirecting, or splitting an edge, or merging two blocks,
then has to update the phis of the blocks involved.
In Pizlo form, the control flow graph knows nothing about SSA [Pizlo25b]_:
blocks have no arguments, phis refer to no blocks, and nothing has to be renumbered when edges change.
Control flow transforms can be written as if there were no SSA.

The price is paid elsewhere.
Data flow analyses have to model the shadows,
and no pass may reorder a phi and an upsilon for it, since the upsilon writes the shadow that the phi reads.
Pizlo gives both an effect on an abstract heap for exactly this purpose [Pizlo25b]_.
The IR has no model of effects yet (see :ref:`ssa-cfg-transforms`).

Validity
~~~~~~~~

Two rules make a graph valid.

- Every use of a value is dominated by its definition. The definition of a phi is its position in its block.
- Every path from the entry of the graph to a phi passes an upsilon for that phi.
  The upsilons of a phi dominate it as a set, although none of them needs to dominate it alone.
  B3 checks this rule with a backward data flow analysis [B3Validate]_.

The second rule makes sure that a phi never reads a shadow that nothing has written. Neither rule asks for more:
a phi need not be at the top of its block,
an upsilon need not be in a predecessor of its phi's block,
a path may pass several upsilons for the same phi, of which the last one counts,
and an upsilon may be in the same block as its phi.
A phi in an unreachable block satisfies the second rule trivially, even without any upsilon.

The IR has no validator yet, so neither rule is checked.

Comparison with Phis with Operand Lists
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suppose every phi comes before all other Insts of its block,
and every predecessor of a phi's block ends with an upsilon for the phi, after all its other Insts.
Then the input of the upsilon in a predecessor is exactly the operand for that predecessor of a phi with an operand list,
and all phis of a block take their values when control enters the block.
Pizlo form contains this form but allows more.
How much more a graph may actually use depends on what the backend realizes, which is the subject of the next section.

The Current Shape
-----------------

What the Builder Produces
~~~~~~~~~~~~~~~~~~~~~~~~~

The builder constructs SSA after Braun et al. (see :ref:`ssa-cfg-construction`), which creates phis lazily.
A phi is created when a variable is read in a block that has no definition of it,
unless the block is sealed and has exactly one predecessor, in which case the read continues there.
A block is sealed once it cannot gain further predecessors.
The phi is appended to the block at the moment it is created.
Phis therefore sit wherever the first read happened, often after operations.
The header of the loop ``for { } lt(i, calldataload(0)) { i := add(i, 1) } { sum := add(sum, i) }`` becomes:

.. code-block:: none

   #1: preds: #0, #2
       v1 = builtin @calldataload v0
       v2 = phi
       v3 = builtin @lt v2, v1
       v4 = phi
       branch v3, #2, #4

Yul evaluates arguments from right to left, so ``calldataload`` comes before the phi for ``i``.
The phi for ``sum`` comes last, because it was created only when the body read ``sum``.

Upsilons are emitted when the block of their phi is sealed, or right away for a phi in a block that is already sealed:
one upsilon in each predecessor of the phi's block, appended to the predecessor.
The builder seals a block only once all its predecessors have their exits,
so those predecessors are complete by then,
and only further upsilons, phis created later, and constants of the entry block can follow an upsilon.

As a result, every graph the builder produces has three properties:
every upsilon sits in an immediate predecessor of its phi's block,
there is exactly one upsilon per predecessor and phi,
and no upsilon is in the same block as its phi.
They follow from how the builder proceeds; nothing states or checks them.

What the Backend Assumes
~~~~~~~~~~~~~~~~~~~~~~~~

The backend realizes the more classical "edge form", not the positional semantics of Pizlo form.
Liveness counts every phi as defined on entry to its block, and the input of every upsilon as used at the end of its block,
wherever they sit in the block (see :ref:`ssa-cfg-analyses`).
Layout generation establishes all phis of a block together in the block's stack-in.
Layout generation and emission take the value of a phi on an edge from the upsilons in the source block of the edge
(``PhiInverse``).

This is correct as long as every predecessor of a phi's block holds an upsilon for the phi
and no upsilon precedes its own phi in the same block,
which is what construction produces and the transforms preserve (see :ref:`ssa-cfg-transforms`).

One place does not follow edge form:
emission stores a spilled phi at the phi's position, while its store trace was recorded against the block's stack-in.
The two agree only if no operation precedes the phi in its block.
Since phis often follow operations, spilling such a phi currently ends in an internal compiler error.

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

   Partly written. Planned content:

   - The pass contract: what a pass may assume, what it must preserve, and the effects model for phis and upsilons.
   - The current pipeline and what it guarantees for its output.
   - For each pass below, how it works and its obligations towards phis and upsilons; the inactive outliner.
   - Planned passes and what they would do to phis and upsilons.

Constant Condition Folding
--------------------------

``transform::foldConstantConditions`` rewrites a conditional jump whose condition is a literal,
or ``eq`` of two literals, into an unconditional jump to the target that is taken,
and removes the block from the predecessors of the other target.
The upsilons in the block for the phis of the dropped target become nops.

.. _ssa-cfg-unreachable-block-cleanup:

Unreachable Block Cleanup
-------------------------

``transform::cleanUnreachableBlocks`` removes the blocks that cannot be reached from the entry, together with their Insts.
Afterwards, predecessor lists name reachable blocks only.

This lets other passes cut a block off without cleaning up after it.
A pass that makes a block unreachable may leave the block's exit as it is,
so that the predecessor lists of its successors still name it.
Such stale entries are fine as long as they name blocks that cannot be reached from the entry;
the next cleanup drops them.

Trivial Phi Elimination
-----------------------

A phi is trivial if all its upsilons provide the same value, not counting the phi itself.
``transform::eliminateTrivialPhis`` replaces every trivial phi by that value and turns its upsilons into nops,
until no trivial phi remains, since eliminating one phi can make others trivial.
Afterwards, every phi receives at least two different values other than itself.
In particular, a block with a single predecessor has no phis.
The pass also removes upsilons whose input is ``Unreachable``,
and replaces a phi that is left without upsilons by an ``Unreachable`` value.

Identity and Nop Removal
------------------------

``transform::removeIdentitiesAndNops`` redirects every input and every exit through chains of identities,
then drops identities and nops from their blocks and frees their slots.
Afterwards, no ``Identity`` or ``Nop`` remains in a block, and no input refers to one.

Jump Threading
--------------

``transform::threadJumps`` lets a block that ends in a jump to a block without other predecessors absorb that block,
unless the target is the entry block or the block itself:
the Insts of the target are appended to the block, and the block takes over the target's exit.
The block thereby becomes the predecessor of the target's successors,
so every upsilon that moves along stays in an immediate predecessor of its phi's block.

Absorbing can turn a loop into a single block that jumps to itself, with its phis at the top and its upsilons at the end.
For example, ``for {} 1 { y := add(y, x) } { x := add(x, 1) sstore(x, y) }`` becomes:

.. code-block:: none

   #1: preds: #0, #1
       v5 = phi
       v7 = phi
       v6 = builtin @add v5, v4
       builtin @sstore v6, v7
       v9 = builtin @add v7, v6
       upsilon v6 -> ^v5
       upsilon v9 -> ^v7
       jump #1

This is how an upsilon can come to share a block with its phi, though only after it.
Absorbing a block that has phis would put the upsilons of the absorbing block ahead of those phis.
The jump threader asserts that an absorbed block has no phis,
which holds because trivial phi elimination runs first and leaves no phis in blocks with a single predecessor.

.. _ssa-cfg-backend-contract:

Backend Contract
================

.. note::

   Not yet written. Planned content:

   - What the backend requires of its input graphs, why,
     and what happens when a requirement is not met.
   - The graphs must not change once the liveness analysis has run.
   - The restriction to edge form: an upsilon in every predecessor of a phi's block, none ahead of its own phi.
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
   - Shadow slots, which realize the positional semantics, what they cost, and the two steps that bring them to par:
     critical-edge splitting, and lowering the trailing upsilons of a block on the edge.

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

   References are added as the chapters citing them are written.

.. [B3IR] WebKit, *B3 Intermediate Representation*, section "Control flow", entries ``Upsilon`` and ``Phi``.
   https://webkit.org/docs/b3/intermediate-representation.html

.. [B3LowerToAir] WebKit, ``Source/JavaScriptCore/b3/B3LowerToAir.cpp``, lowering of ``Phi``.
   https://github.com/WebKit/WebKit/blob/d9fb479bd09e63bd0659cacf0ad8df4431e592db/Source/JavaScriptCore/b3/B3LowerToAir.cpp#L6446-L6450

.. [B3Validate] WebKit, ``Source/JavaScriptCore/b3/B3Validate.cpp``, ``validatePhisAreDominatedByUpsilons``.
   https://github.com/WebKit/WebKit/blob/df3a6b749ba3173f558ad086576f3160bebd9ff5/Source/JavaScriptCore/b3/B3Validate.cpp#L1092-L1133

.. [Pizlo25a] Filip Pizlo, *Pizlo SSA Form (short version)*, 2025.
   https://gist.github.com/pizlonator/79b0aa601912ff1a0eb1cb9253f5e98d

.. [Pizlo25b] Filip Pizlo, *How I implement SSA form*, 2025.
   https://gist.github.com/pizlonator/cf1e72b8600b1437dda8153ea3fdb963
