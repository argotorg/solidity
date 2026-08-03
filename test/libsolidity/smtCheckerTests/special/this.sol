contract C
{
	function f(address a) public view {
		assert(a == address(this));
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (52-78): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x0\n\nTransaction trace:\nC.constructor()\nC.f(0x0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
