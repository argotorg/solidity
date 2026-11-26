pragma abicoder v2;

contract C {
	struct T {
		uint t;
	}
	struct S {
		uint x;
		T t;
		bool b;
		uint[] a;
	}

	S public s;

	function f() public view {
		S memory r = this.s();
		assert(r.x == s.x); // this should hold
		assert(r.b == s.b); // this should hold
		assert(r.t.t == s.t.t); // this should hold
		assert(r.a.length == s.a.length); // this should hold
		assert(r.b == true); // this should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (369-388): CHC: Assertion violation happens here.\nCounterexample:\ns = {x: 0, t: {t: 0}, b: false, a: []}\nr = {x: 0, t: {t: 0}, b: false, a: []}\n\nTransaction trace:\nC.constructor()\nState: s = {x: 0, t: {t: 0}, b: false, a: []}\nC.f()
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
