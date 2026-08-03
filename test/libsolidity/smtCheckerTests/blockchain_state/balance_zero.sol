contract C {
	constructor() {
		assert(address(this).balance == 0); // should fail because there might be funds from before deployment
		assert(address(this).balance > 0); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (32-66): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()
// Warning 6328: (137-170): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
