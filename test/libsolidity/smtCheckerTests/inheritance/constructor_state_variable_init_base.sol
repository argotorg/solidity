contract C {
	uint x = 2;
}

contract D is C {
	constructor() {
		assert(x == 2);
		assert(x == 3);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (84-98): CHC: Assertion violation happens here.\nCounterexample:\nx = 2\n\nTransaction trace:\nD.constructor()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
