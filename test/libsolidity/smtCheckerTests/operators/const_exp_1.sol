contract C {
	uint constant x = 2;
	uint constant y = x ** 10;

	function f() public view {
		assert(y == 2 ** 10);
		assert(y == 1024);
		assert(y == 14); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 2018: (65-173): Function state mutability can be restricted to pure
// Warning 6328: (139-154): CHC: Assertion violation happens here.\nCounterexample:\nx = 2, y = 1024\n\nTransaction trace:\nC.constructor()\nState: x = 2, y = 1024\nC.f()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
