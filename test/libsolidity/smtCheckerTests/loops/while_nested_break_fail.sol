contract C
{
	function f(uint x, uint y, bool b, bool c) public pure {
		require(x < 10);
		while (x < 10) {
			if (b) {
				++x;
				if (x == 10)
					x = 15;
			}
			else {
				require(y < 10);
				while (y < 10) {
					if (c)
						++y;
					else {
						y = 20;
						break;
					}
				}
				assert(y >= 15);
				x = 15;
				break;
			}
		}
		assert(x >= 20);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (296-311): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\ny = 10\nb = false\nc = true\n\nTransaction trace:\nC.constructor()\nC.f(0, 9, false, true)
// Warning 6328: (347-362): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 15\ny = 20\nb = false\nc = false\n\nTransaction trace:\nC.constructor()\nC.f(0, 0, false, false)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
