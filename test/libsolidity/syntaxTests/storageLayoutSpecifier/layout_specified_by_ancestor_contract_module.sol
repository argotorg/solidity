==== Source: C ====
import "M" as M;
import "N" as N;

contract C is M.A, N.A layout at 0xABCD {}
==== Source: M ====
contract A layout at 0x1234 {}

==== Source: N ====
contract A {}

// ----
// TypeError 8894: (C:49-52): Cannot inherit from a contract with a custom storage layout.
