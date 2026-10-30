********************************
Solidity v0.9.0 Breaking Changes
********************************

This section highlights the main breaking changes introduced in Solidity
version 0.9.0.
For the full list check
`the release changelog <https://github.com/argotorg/solidity/releases/tag/v0.9.0>`_.

Silent Changes of the Semantics
===============================

This section lists changes where existing code changes its behavior without
the compiler notifying you about it.


New Restrictions
================

This section lists changes that might cause existing contracts to not compile anymore.

* Virtual modifiers are disallowed.

Interface Changes
=================

This section lists changes that are unrelated to the language itself, but that have an effect on the interfaces of
the compiler. These may change the way how you use the compiler on the command-line, how you use its programmable
interface, or how you analyze the output produced by it.

* EVM versions ``homestead``, ``tangerineWhistle``, ``spuriousDragon`` and ``byzantium`` are no longer supported.
  CLI and JSON interfaces now reject them.

* BMC engine of SMTChecker was removed. CLI and JSON interfaces now reject it.
  The associated option `--model-checker-bmc-loop-iterations` and `constantCondition` verification target were also removed.

How to update your code
=======================

* Virtual modifiers can, in most cases, be replaced by a non-virtual modifier and a virtual helper function.
  Non-virtual modifier can delegate the work to the virtual helper that derived contracts can override.


