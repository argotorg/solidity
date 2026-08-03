contract C {
	struct S {
		uint x;
		uint[] a;
	}
	S s;
	function f(uint _x) public {
		s.a.pop();
		s.a.length;
		s.a.push();
		s.x = _x;
		s.a.pop();
		s.a.push();
		s.a.push();
		s.a[0] = _x;
		assert(s.a[1] == s.a[0]);
		s.a.pop();
		s.a.pop();
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 2529: (88-97): CHC: Empty array "pop" happens here.\nCounterexample:\ns = {x: 0, a: []}\n_x = 0\n\nTransaction trace:\nC.constructor()\nState: s = {x: 0, a: []}\nC.f(0)
// Warning 6328: (197-221): CHC: Assertion violation happens here.\nCounterexample:\ns = {x: 32279, a: [32279, 0]}\n_x = 32279\n\nTransaction trace:\nC.constructor()\nState: s = {x: 0, a: []}\nC.f(32279)
// Info 1391: CHC: 6 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
