contract C {
	uint a;
	constructor() {
		a = 2;
	}
}

contract B is C {
}

contract A is B {
	constructor(uint x) B() {
		assert(a == 2);
		assert(a == 3);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 5667: (106-112): Unused function parameter. Remove or comment out the variable name to silence this warning.
// Warning 6328: (140-154): CHC: Assertion violation happens here.\nCounterexample:\na = 2\nx = 0\n\nTransaction trace:\nA.constructor(0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
