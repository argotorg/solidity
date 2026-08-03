contract C {
	function f() public pure returns (address[2] memory a) {
		assert(a.length == 2); // should hold
		assert(a.length < 2); // should fail
		assert(a.length > 2); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (113-133): CHC: Assertion violation happens here.\nCounterexample:\n\na = [0x0, 0x0]\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (152-172): CHC: Assertion violation happens here.\nCounterexample:\n\na = [0x0, 0x0]\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
