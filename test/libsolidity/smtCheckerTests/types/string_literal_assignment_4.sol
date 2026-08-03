contract C {
	function g() internal pure returns (bytes32, bytes16) {
		return ("test", "testz");
	}

	function f(bytes32 _x) public pure {
		require(_x == "test");
		bytes32 y;
		bytes16 z;
		(y, z) = g();
		assert(_x == y);
		assert(_x == z);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (228-243): CHC: Assertion violation happens here.\nCounterexample:\n\n_x = 0x7465737400000000000000000000000000000000000000000000000000000000\ny = 0x7465737400000000000000000000000000000000000000000000000000000000\nz = 0x746573747a0000000000000000000000\n\nTransaction trace:\nC.constructor()\nC.f(0x7465737400000000000000000000000000000000000000000000000000000000)\n    C.g() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
