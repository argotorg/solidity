contract C {
	struct S {
		uint x;
		uint[] a;
	}
	S s1;
	S s2;
	function f(bool b) public {
		S storage s3 = b ? s1 : s2;
		// Disabled because Spacer 4.8.9 seg fauts.
		//assert(s3.x == s1.x);
		//assert(s3.x == s2.x);
		// This is safe.
		assert(s3.x == s1.x || s3.x == s2.x);
		// This fails as false positive because of lack of support to aliasing.
		s3.x = 42;
		assert(s3.x == s1.x || s3.x == s2.x);
	}
	function g(bool b, uint _x) public {
		if (b)
			s1.x = _x;
		else
			s2.x = _x;
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (369-405): CHC: Assertion violation happens here.\nCounterexample:\ns1 = {x: 35, a: [9, 9, 9, 9, 9, 36, 9, 9, 9, 9]}, s2 = {x: 43, a: [11, 11, 11, 11, 11, 77, 11, 11, 11, 11, 11, 11]}\nb = true\ns3 = {x: 42, a: []}\n\nTransaction trace:\nC.constructor()\nState: s1 = {x: 0, a: []}, s2 = {x: 0, a: []}\nC.f(true)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
