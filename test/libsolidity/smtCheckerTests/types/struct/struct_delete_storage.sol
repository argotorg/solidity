pragma abicoder               v2;

contract C {
	struct S {
		uint x;
		uint[] a;
	}
	S s1;
	function g(S memory s2) public {
		s1.x = s2.x;
		s1.a = s2.a;
	}
	function f(S memory s2) public {
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
// Warning 6328: (208-228): CHC: Assertion violation happens here.\nCounterexample:\ns1 = {x: 0, a: []}\ns2 = {x: 8856, a: [9, 9, 9, 9, 9, 27, 9, 9, 9, 9]}\n\nTransaction trace:\nC.constructor()\nState: s1 = {x: 0, a: []}\nC.f({x: 8856, a: [9, 9, 9, 9, 9, 27, 9, 9, 9, 9]})
// Warning 6328: (232-266): CHC: Assertion violation happens here.\nCounterexample:\ns1 = {x: 0, a: []}\ns2 = {x: 11798, a}\n\nTransaction trace:\nC.constructor()\nState: s1 = {x: 0, a: []}\nC.f({x: 11798, a})
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
