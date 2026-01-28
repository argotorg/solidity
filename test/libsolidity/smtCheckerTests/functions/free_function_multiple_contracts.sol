function check(uint x) pure {
	assert(x > 0);
}

contract C {
	function a() public pure {
		check(1);
	}
}

contract D {
	function b(uint x) public pure {
		check(x);
	}
}
// ====
// SMTEngine: chc
// SMTIgnoreCex: no
// ----
// Warning 6328: (31-44): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nD.constructor()\nD.b(0)\n    check(0) -- internal call
