contract C
{
	function f(string memory s1, string memory s2) public pure {
		assert(bytes(s1).length == bytes(s2).length);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (77-121): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.f(s1, s2) -- counterexample incomplete; parameter name used instead of value
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
