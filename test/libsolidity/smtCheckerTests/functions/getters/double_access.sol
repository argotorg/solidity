contract C {
	struct S {
		uint u;
	}

	S public s;

	function f() public view {
		uint u = this.s();
		uint v = this.s();
		assert(u == s.u); // should hold
		assert(u == v); // should hold
		assert(u == 1); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (193-207): CHC: Assertion violation happens here.\nCounterexample:\ns = {u: 0}\nu = 0\nv = 0\n\nTransaction trace:\nC.constructor()\nState: s = {u: 0}\nC.f()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
