contract C
{
	function f(C c, C d) public pure {
		assert(address(c) == address(c));
		address a = address(c);
		require(c == d);
		assert(a == address(d));
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9170: (121-127): Comparison of variables of contract type is deprecated and scheduled for removal. Use an explicit cast to address type and compare the addresses instead.
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
