contract C
{
	function f(uint8 x) public pure returns (uint8) {
		x = 100;
		uint8 y = x * 3;
		assert(y == 44);
		x = 128;
		y = x * 4;
		assert(y == 0);
		return y;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (87-92): CHC: Overflow (resulting value larger than 255) happens here.\nCounterexample:\n\nx = 100\n = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
