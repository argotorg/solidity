contract C  {
	function f(uint x, uint y) public pure returns (uint) {
		return x + y;
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (80-85): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\n\nx = 1\ny = 115792089237316195423570985008687907853269984665640564039457584007913129639935\n = 0\n\nTransaction trace:\nC.constructor()\nC.f(1, 115792089237316195423570985008687907853269984665640564039457584007913129639935)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
