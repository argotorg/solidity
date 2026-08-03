contract C {
	uint a;
	constructor() {
		a = 2;
	}
}

contract B is C {
}

contract A is B {
	constructor(uint x) {
		assert(a == 3);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 5667: (106-112): Unused function parameter. Remove or comment out the variable name to silence this warning.
// Warning 6328: (118-132): CHC: Assertion violation happens here.\nCounterexample:\na = 2\nx = 0\n\nTransaction trace:\nA.constructor(0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
