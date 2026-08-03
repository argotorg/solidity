contract C {
	function f() public payable {
		assert(msg.value > 0);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (46-67): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.f(){ msg.value: 0 }
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
