contract C {
	function f(bytes32 _x) public pure {
		require(_x != "test");
		bytes32 y = _x;
		bytes32 z = _x;
		assert(z == "test");
		assert(y != "testx");
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (114-133): CHC: Assertion violation happens here.\nCounterexample:\n\n_x = 0x0\ny = 0x0\nz = 0x0\n\nTransaction trace:\nC.constructor()\nC.f(0x0)
// Warning 6328: (137-157): CHC: Assertion violation happens here.\nCounterexample:\n\n_x = 0x7465737478000000000000000000000000000000000000000000000000000000\ny = 0x7465737478000000000000000000000000000000000000000000000000000000\nz = 0x7465737478000000000000000000000000000000000000000000000000000000\n\nTransaction trace:\nC.constructor()\nC.f(0x7465737478000000000000000000000000000000000000000000000000000000)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
