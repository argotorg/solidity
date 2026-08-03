contract C {
	function f(bytes memory d) public pure {
		(bool a, uint x) = abi.decode(d, (bool, uint));
		assert(a == (x == 2)); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (107-128): CHC: Assertion violation happens here.\nCounterexample:\n\na = true\nx = 20540\n\nTransaction trace:\nC.constructor()\nC.f(d) -- counterexample incomplete; parameter name used instead of value
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
