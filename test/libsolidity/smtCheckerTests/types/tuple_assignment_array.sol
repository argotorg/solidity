contract C
{
	uint[] a;
	function p() public { a.push(); }
	function g(uint x, uint y) public {
		require(x < a.length);
		require(y < a.length);
		require(x != y);
		(a[x], a[y]) = (2, 4);
		assert(a[x] == 2);
		assert(a[y] == 4);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 6 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
