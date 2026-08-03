contract C  {
	function f(uint x, uint y) public pure returns (uint) {
		return x - y;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 3944: (80-85): CHC: Underflow (resulting value less than 0) happens here.\nCounterexample:\n\nx = 0\ny = 1\n = 0\n\nTransaction trace:\nC.constructor()\nC.f(0, 1)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
