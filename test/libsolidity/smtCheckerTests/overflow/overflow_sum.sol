contract C
{
	function f(uint8 x) public pure returns (uint8) {
		uint8 y;
		unchecked { y = x + 255; }
		require(y >= x);
		x = 255;
		unchecked { y = x + 1; }
		assert(y == 0);
		y = x + 255;
		assert(y == 254);
		return y;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (185-192): CHC: Overflow (resulting value larger than 255) happens here.\nCounterexample:\n\nx = 255\n = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
