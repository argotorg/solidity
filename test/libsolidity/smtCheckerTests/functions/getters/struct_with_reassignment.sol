contract C {
	struct S {
		uint x;
		bool b;
	}

	S public s;

	constructor() {
		s.x = 1;
		s.b = false;
	}

	function f() public {
		S memory r = this.s();
		assert(r.x == s.x); // this should hold
		assert(r.b == s.b); // this should hold
		assert(r.b == true); // this should fail
		s.x = 42;
		S memory q = this.s();
		assert(q.b == r.b); // this should hold
		assert(q.x == r.x); // this should fail

	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (244-263): CHC: Assertion violation happens here.\nCounterexample:\ns = {x: 1, b: false}\nr = {x: 1, b: false}\nq = {x: 0, b: false}\n\nTransaction trace:\nC.constructor()\nState: s = {x: 1, b: false}\nC.f()
// Warning 6328: (366-384): CHC: Assertion violation happens here.\nCounterexample:\ns = {x: 42, b: false}\nr = {x: 1, b: false}\nq = {x: 42, b: false}\n\nTransaction trace:\nC.constructor()\nState: s = {x: 1, b: false}\nC.f()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
