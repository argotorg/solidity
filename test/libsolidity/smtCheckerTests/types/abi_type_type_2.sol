contract C {
	function f(bytes memory d) public pure {
		assert(abi.decode(d, (bool))); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (57-86): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.f(d) -- counterexample incomplete; parameter name used instead of value
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
