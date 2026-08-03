contract C {
	struct S {
		uint x;
		mapping (uint => uint) m;
	}
	S s1;
	S s2;
	function f() public view {
		// Disabled because Spacer 4.8.9 seg faults.
		//assert(s1.m[0] == s2.m[0]);
	}
	function g(uint a, uint b) public {
		s1.m[a] = b;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
