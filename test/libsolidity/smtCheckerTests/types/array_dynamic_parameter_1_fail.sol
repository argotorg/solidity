contract C
{
	function f(uint[] memory array, uint x, uint y) public pure {
		require(x < array.length);
		array[x] = 200;
		require(x == y);
		assert(array[y] > 300);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (144-166): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f(array, 0, 0) -- counterexample incomplete; parameter name used instead of value
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
