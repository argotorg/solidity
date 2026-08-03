pragma abicoder               v2;

contract C {
	struct S {
		uint x;
		uint[] a;
	}
	function f(S memory s1, S memory s2) public pure {
		delete s1;
		s1.x = 100;
		s1.x--;
		--s1.x;
		assert(s1.x == 98);
		assert(s1.x == s2.x);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (208-228): CHC: Assertion violation happens here.\nCounterexample:\n\ns1 = {x: 98, a: []}\ns2 = {x: 99, a: [9, 9, 9, 9, 9, 21, 9, 9, 9, 9]}\n\nTransaction trace:\nC.constructor()\nC.f({x: 0, a: []}, {x: 0, a: []})
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
