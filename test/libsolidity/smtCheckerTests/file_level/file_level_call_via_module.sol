==== Source: a.sol ====
function f(uint) pure returns (uint) { return 7; }
function f(bytes memory x) pure returns (uint) { return x.length; }
==== Source: b.sol ====
import "a.sol" as M;
contract C {
	function f() internal pure returns (uint, uint) {
		return (M.f(2), M.f("abc"));
	}
	function p() public pure {
		(uint a, uint b) = f();
		assert(a == 7); // should hold
		assert(a == 9); // should fail
		assert(b == 3); // should hold
		assert(b == 5); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6328: (b.sol:208-222): CHC: Assertion violation happens here.\nCounterexample:\n\na = 7\nb = 3\n\nTransaction trace:\nC.constructor()\nC.p()\n    C.f() -- internal call\n        a.sol:f(2) -- internal call\n        a.sol:f([0x61, 0x62, 0x63]) -- internal call
// Warning 6328: (b.sol:274-288): CHC: Assertion violation happens here.\nCounterexample:\n\na = 7\nb = 3\n\nTransaction trace:\nC.constructor()\nC.p()\n    C.f() -- internal call\n        a.sol:f(2) -- internal call\n        a.sol:f([0x61, 0x62, 0x63]) -- internal call
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
