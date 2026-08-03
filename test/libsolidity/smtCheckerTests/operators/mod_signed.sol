contract C {
	function f(int x, int y) public pure {
		require(y != 0);
		require(x == 42);
		int z1 = x % y;
		int z2 = -x % y;
		assert(z1 == -z2);
		assert((x >= 0 && z1 >=0) || (x <= 0 && z1 <= 0));
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (131-148): CHC: Assertion violation might happen here.
// Info 1391: CHC: 7 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
