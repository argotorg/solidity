contract A {
	int x = 0;

	modifier m {
		assert(x == 0); // should hold
		assert(x == 42); // should fail
		_;
	}
}
contract C is A {
	function f() public A.m returns (uint) {
	}
}
// ====
// SMTEngine: chc
// ----
// Warning 6328: (75-90): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\n = 0\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
