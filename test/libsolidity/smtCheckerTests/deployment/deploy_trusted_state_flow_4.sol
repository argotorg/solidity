contract D {
	bool b;
	function s() public { b = true; }
	function f() public view returns (bool) { return b; }
}

contract C {
	D d;
	constructor() {
		d = new D();
	}
	function g() public view {
		assert(d.f()); // should fail
	}
}
// ====
// SMTEngine: all
// SMTExtCalls: trusted
// ----
// Warning 6328: (199-212): CHC: Assertion violation happens here.\nCounterexample:\nd = 28880\n\nTransaction trace:\nC.constructor()\nState: d = 28880\nC.g()\n    D.f() -- trusted external call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
