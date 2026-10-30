contract C {
	function mul(uint8 a, uint8 b) public pure returns (uint8) {
		if (a == 0) {
			return 0;
		}
		uint8 c = a * b;
		require(c / a == b);
		return c;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (120-125): CHC: Overflow (resulting value larger than 255) happens here.\nCounterexample:\n\na = 128\nb = 2\n = 0\nc = 0\n\nTransaction trace:\nC.constructor()\nC.mul(128, 2)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
