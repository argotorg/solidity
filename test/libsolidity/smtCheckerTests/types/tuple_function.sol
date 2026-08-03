contract C
{
	function f() internal pure returns (uint, uint) {
		return (2, 3);
	}
	function g() public pure {
		uint x;
		uint y;
		(x,y) = f();
		assert(x == 1);
		assert(y == 4);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (149-163): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 2\ny = 3\n\nTransaction trace:\nC.constructor()\nC.g()\n    C.f() -- internal call
// Warning 6328: (167-181): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 2\ny = 3\n\nTransaction trace:\nC.constructor()\nC.g()\n    C.f() -- internal call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
