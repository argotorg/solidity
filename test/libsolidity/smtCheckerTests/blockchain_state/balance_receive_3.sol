contract C {
	constructor() payable {
		assert(address(this).balance == msg.value); // should fail because there might be funds from before deployment
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (40-82): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor(){ msg.value: 2437 }
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
