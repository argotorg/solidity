contract C
{
	bytes32 x;
	function f(bytes8 y) public view {
		assert(x != y);
		assert(x != g());
	}
	function g() public view returns (bytes32) {
		return x;
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (63-77): CHC: Assertion violation happens here.\nCounterexample:\nx = 0x0\ny = 0x0\n\nTransaction trace:\nC.constructor()\nState: x = 0x0\nC.f(0x0)
// Warning 6328: (81-97): CHC: Assertion violation happens here.\nCounterexample:\nx = 0x0\ny = 0x0\n\nTransaction trace:\nC.constructor()\nState: x = 0x0\nC.f(0x0)\n    C.g() -- internal call
