contract C {
	function f() public pure {
		int16 x = 1;
		assert(~x == 0);
		x = 0xff;
		assert(~x == 0);
		x = 0x0f;
		assert(~x == 0xf0);
		x = -1;
		assert(~x != 0);
		x = -2;
		assert(~x == 1);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (58-73): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 1\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (89-104): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 255\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (120-138): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 15\n\nTransaction trace:\nC.constructor()\nC.f()
// Warning 6328: (152-167): CHC: Assertion violation happens here.\nCounterexample:\n\nx = (- 1)\n\nTransaction trace:\nC.constructor()\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
