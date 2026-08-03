contract C {
	uint[2] a;
	uint x = f();
	constructor() {
		assert(a.length == 2); // should hold
		assert(x == 2); // should hold
		assert(a.length < 2); // should fail
		assert(a.length > 2); // should fail
	}
	function f() internal view returns (uint) {
		assert(a.length == 2); // should hold
		assert(a.length < 2); // should fail
		assert(a.length > 2); // should fail
		return a.length;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (132-152): CHC: Assertion violation happens here.\nCounterexample:\na = [0, 0], x = 2\n\nTransaction trace:\nC.constructor()
// Warning 6328: (171-191): CHC: Assertion violation happens here.\nCounterexample:\na = [0, 0], x = 2\n\nTransaction trace:\nC.constructor()
// Warning 6328: (298-318): CHC: Assertion violation happens here.\nCounterexample:\na = [0, 0], x = 0\n\nTransaction trace:\nC.constructor()
// Warning 6328: (337-357): CHC: Assertion violation happens here.\nCounterexample:\na = [0, 0], x = 0\n\nTransaction trace:\nC.constructor()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
