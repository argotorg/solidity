contract C
{
	function f(C c, address a) public pure {
		assert(address(c) == a);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (57-80): CHC: Assertion violation happens here.\nCounterexample:\n\nc = 0\na = 0x01\n\nTransaction trace:\nC.constructor()\nC.f(0, 0x01)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
