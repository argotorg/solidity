==== Source: A.sol ====
contract A { function a() pure public { assert(false); } }
==== Source: B.sol ====
import "A.sol";
contract B { function b() pure public { } }
// ====
// SMTContract: B.sol:B
// SMTEngine: chc
// ----
