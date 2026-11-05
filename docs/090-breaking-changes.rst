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

* ABI coder v1 has been removed and ``pragma abicoder v1;`` is no longer accepted.
  ABI coder v2, which has been the default since Solidity 0.8.0, is now the only implementation.

* Deprecated ``pragma experimental SMTChecker`` is no longer accepted.
  SMTChecker can be enabled by setting model checker engine to ``chc``.


Interface Changes
=================

This section lists changes that are unrelated to the language itself, but that have an effect on the interfaces of
the compiler. These may change the way how you use the compiler on the command-line, how you use its programmable
interface, or how you analyze the output produced by it.

* EVM versions ``homestead``, ``tangerineWhistle``, ``spuriousDragon`` and ``byzantium`` are no longer supported.
  CLI and JSON interfaces now reject them.

* BMC engine of SMTChecker was removed. CLI and JSON interfaces now reject it.
  The associated option `--model-checker-bmc-loop-iterations` and `constantCondition` verification target were also removed.

* cvc5 can no longer be selected as the SMT solver to be used by SMTChecker.

How to update your code
=======================

* Remove ``pragma abicoder v1;``.
  Note that ABI coder v2 performs more validation on the inputs, which makes some function calls more expensive
  and can make calls revert that did not revert with ABI coder v1 when they contain data that does not conform
  to the parameter types.

* Remove ``pragma experimental SMTChecker;``.

