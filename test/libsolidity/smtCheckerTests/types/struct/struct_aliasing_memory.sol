pragma abicoder               v2;

contract C {
	struct S {
		uint x;
		uint[] a;
	}
	function f(S memory s1, S memory s2, bool b) public pure {
		S memory s3 = b ? s1 : s2;
		assert(s3.x == s1.x);
		assert(s3.x == s2.x);
		// This is safe.
		assert(s3.x == s1.x || s3.x == s2.x);
		// This fails as false positive because of lack of support to aliasing.
		s3.x = 42;
		assert(s3.x == s1.x || s3.x == s2.x);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (176-196): CHC: Assertion violation happens here.\nCounterexample:\n\ns1 = {x: 11798, a: [9, 9, 9, 9, 9, 47, 9, 9, 9, 9]}\ns2 = {x: 11797, a: [11, 11, 11, 11, 11, 30, 11, 11, 11, 11, 11, 11]}\nb = false\ns3 = {x: 11797, a: [11, 11, 11, 11, 11, 30, 11, 11, 11, 11, 11, 11]}\n\nTransaction trace:\nC.constructor()\nC.f({x: 11798, a: [9, 9, 9, 9, 9, 47, 9, 9, 9, 9]}, {x: 11797, a: [11, 11, 11, 11, 11, 30, 11, 11, 11, 11, 11, 11]}, false)
// Warning 6328: (200-220): CHC: Assertion violation happens here.\nCounterexample:\n\ns1 = {x: 8856, a: [11, 11, 11, 11, 11, 30, 11, 11, 11, 11, 11, 11]}\ns2 = {x: 8855, a: [9, 9, 9, 9, 9, 47, 9, 9, 9, 9]}\nb = true\ns3 = {x: 8856, a: [11, 11, 11, 11, 11, 30, 11, 11, 11, 11, 11, 11]}\n\nTransaction trace:\nC.constructor()\nC.f({x: 8856, a: [11, 11, 11, 11, 11, 30, 11, 11, 11, 11, 11, 11]}, {x: 8855, a: [9, 9, 9, 9, 9, 47, 9, 9, 9, 9]}, true)
// Warning 6328: (370-406): CHC: Assertion violation happens here.\nCounterexample:\n\ns1 = {x: 7, a: [18, 18, 18, 18, 18, 72, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18]}\ns2 = {x: 35, a: [10, 10, 10, 10, 10, 110, 10, 10, 10, 10, 10]}\nb = true\ns3 = {x: 42, a: [12, 12, 12, 12, 12, 59, 12, 12, 12, 12, 12, 12, 12]}\n\nTransaction trace:\nC.constructor()\nC.f({x: 11797, a: [12, 12, 12, 12, 12, 59, 12, 12, 12, 12, 12, 12, 12]}, {x: 11798, a: [14, 14, 14, 14, 14, 94, 14, 14, 14, 14, 14, 14, 14, 14, 14]}, true)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
