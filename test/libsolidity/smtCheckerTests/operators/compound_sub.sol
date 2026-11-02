contract C
{
	function f(uint x) public pure {
		require(x < 100);
		uint y = 200;
		y -= y - x;
		assert(y >= 0);
		assert(y < 90);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (117-131): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 90\ny = 90\n\nTransaction trace:\nC.constructor()\nC.f(90)
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
