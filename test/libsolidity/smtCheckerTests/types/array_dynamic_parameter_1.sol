contract C
{
	function f(uint[] memory array, uint x, uint y) public pure {
		require(x < array.length);
		array[x] = 200;
		require(x == y);
		assert(array[y] > 100);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
