pragma abicoder               v2;

contract C {
	struct S {
		uint x;
		uint[] a;
	}
	function f(S memory s1, S memory s2) public pure {
		delete s1;
		assert(s1.x == s2.x);
		assert(s1.a.length == s2.a.length);
		assert(s1.a.length == 0);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (152-172): CHC: Assertion violation happens here.\nCounterexample:\n\ns1 = {x: 0, a: []}\ns2 = {x: 8856, a: [9, 9, 9, 9, 9, 28, 9, 9, 9, 9]}\n\nTransaction trace:\nC.constructor()\nC.f({x: 0, a: []}, {x: 8856, a: [9, 9, 9, 9, 9, 28, 9, 9, 9, 9]})
// Warning 6328: (176-210): CHC: Assertion violation happens here.\nCounterexample:\n\ns1 = {x: 0, a: []}\ns2 = {x: 8856, a}\n\nTransaction trace:\nC.constructor()\nC.f({x: 0, a: []}, {x: 8856, a})
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
