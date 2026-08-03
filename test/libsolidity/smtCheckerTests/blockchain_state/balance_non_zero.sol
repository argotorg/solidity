contract C {
	constructor() payable {
		assert(address(this).balance == 0); // should fail
		assert(address(this).balance > 0); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (40-74): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor(){ msg.value: 0 }
// Warning 6328: (93-126): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor(){ msg.value: 0 }
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
