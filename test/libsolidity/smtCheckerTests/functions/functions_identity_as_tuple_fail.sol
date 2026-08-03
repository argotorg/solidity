contract C
{
	function h(uint x) public pure returns (uint) {
		return x;
	}
	function g() public pure {
		uint x;
		x = (h)(0);
		assert(x > 0);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (131-144): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.h(0)\nC.g()\n    C.h(0) -- internal call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
