contract C
{
	function f(int8 x) public pure returns (int8) {
		x = 100;
		int8 y;
		unchecked { y = x * 2; }
		assert(y == -56);
		y = x * 100;
		assert(y == 16);
		return y;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (136-143): CHC: Overflow (resulting value larger than 127) happens here.\nCounterexample:\n\nx = 100\n = 0\ny = (- 56)\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
