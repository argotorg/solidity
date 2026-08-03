library L
{
	function add(uint x, uint y) internal pure returns (uint) {
		require(x < 1000);
		require(y < 1000);
		return x + y;
	}
}

contract C
{
	function f(uint x) public pure {
		uint y = L.add(x, 999);
		assert(y < 1000);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (212-228): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 1\ny = 1000\n\nTransaction trace:\nC.constructor()\nC.f(1)\n    L.add(1, 999) -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
