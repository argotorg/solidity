contract D {
	uint x;
	function s(uint _x) public { x = _x; }
	function f() public view returns (uint) { return x; }
}

contract C {
	D d;
	constructor() {
		d = new D();
	}
	function g() public view {
		assert(d.f() == 0); // should fail
	}
}
// ====
// SMTContract: C
// SMTEngine: all
// SMTExtCalls: trusted
// ----
// Warning 6328: (204-222): CHC: Assertion violation happens here.\nCounterexample:\nd = (- 1)\n\nTransaction trace:\nC.constructor()\nState: d = (- 1)\nC.g()\n    D.f() -- trusted external call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
