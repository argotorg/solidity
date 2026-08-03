contract C {
	struct S {
		uint x;
		uint[] a;
	}
	S s;
	function p() public { s.a.push(); }
	function f(uint _x) public {
		require(s.a.length >= 2);
		s.x = _x;
		s.a[0] = _x;
		assert(s.a[1] == s.a[0]);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (180-204): CHC: Assertion violation happens here.\nCounterexample:\ns = {x: 11798, a: [11798, 0]}\n_x = 11798\n\nTransaction trace:\nC.constructor()\nState: s = {x: 0, a: []}\nC.p()\nState: s = {x: 0, a: [0]}\nC.p()\nState: s = {x: 0, a: [0, 0]}\nC.f(11798)
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
