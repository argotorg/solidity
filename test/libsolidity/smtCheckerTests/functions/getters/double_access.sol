contract C {
	struct S {
		uint u;
	}

	S public s;

	function f() public view {
		S memory a = this.s();
		S memory b = this.s();
		assert(a.u == s.u); // should hold
		assert(a.u == b.u); // should hold
		assert(a.u == 1); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (207-223): CHC: Assertion violation happens here.\nCounterexample:\ns = {u: 0}\na = {u: 0}\nb = {u: 0}\n\nTransaction trace:\nC.constructor()\nState: s = {u: 0}\nC.f()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
