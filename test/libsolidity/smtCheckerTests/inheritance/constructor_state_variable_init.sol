contract C {
	uint x = 2;
	constructor () {
		assert(x == 2);
		assert(x == 3);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (64-78): CHC: Assertion violation happens here.\nCounterexample:\nx = 2\n\nTransaction trace:\nC.constructor()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
