contract C {
	function f() public pure {
		bytes32 x = 0x00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff;
		bytes1 z = 0x00;
		bytes1 o = 0xff;
		assert(x[0] == z);
		assert(x[31] == o);
		assert(x[0] == x[22]);
		assert(x[0] == x[23]);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (231-252): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0xff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff\nz = 0x0\no = 0xff\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 9 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
