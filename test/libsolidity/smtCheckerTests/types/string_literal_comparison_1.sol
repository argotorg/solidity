contract C {
	function f(bytes32 _x) public pure {
		require(_x == "test");
		bytes32 y = _x;
		bytes32 z = _x;
		assert(z == "test");
		assert(y == "testx");
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (137-157): CHC: Assertion violation happens here.\nCounterexample:\n\n_x = 0x7465737400000000000000000000000000000000000000000000000000000000\ny = 0x7465737400000000000000000000000000000000000000000000000000000000\nz = 0x7465737400000000000000000000000000000000000000000000000000000000\n\nTransaction trace:\nC.constructor()\nC.f(0x7465737400000000000000000000000000000000000000000000000000000000)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
