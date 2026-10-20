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
// Warning 6328: (57-80): CHC: Assertion violation happens here.\nCounterexample:\n\nc = 1\na = 0x0\n\nTransaction trace:\nC.constructor()\nC.f(1, 0x0)
