==== Source: A.sol ====
contract A { function a() pure public { assert(false); } }
==== Source: B.sol ====
import "A.sol";
contract B { function b(A a) pure public { a.a(); } }
// ====
// SMTContract: B.sol:B
// SMTEngine: chc
// SMTExtCalls: trusted
// ----
// Warning 6328: (A.sol:40-53): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0\n\nTransaction trace:\nB.constructor()\nB.b(0)\n    A.a() -- trusted external call
