contract C {
	uint a;
	constructor(uint x) {
		a = x;
	}
}

contract A is C {
	constructor() C(2) {
		assert(a == 2);
		assert(a == 3);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (120-134): CHC: Assertion violation happens here.\nCounterexample:\na = 2\n\nTransaction trace:\nA.constructor()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
