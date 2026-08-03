contract C {
	uint[2] a;
	function f() public view {
		assert(a.length == 2); // should hold
		assert(a.length < 2); // should fail
		assert(a.length > 2); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (95-115): CHC: Assertion violation happens here.\nCounterexample:\na = [0, 0]\n\nTransaction trace:\nC.constructor()\nState: a = [0, 0]\nC.f()
// Warning 6328: (134-154): CHC: Assertion violation happens here.\nCounterexample:\na = [0, 0]\n\nTransaction trace:\nC.constructor()\nState: a = [0, 0]\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
