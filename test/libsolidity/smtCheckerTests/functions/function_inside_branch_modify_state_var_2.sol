contract C
{
	uint x;
	function f() internal {
		require(x < 10000);
		x = x + 1;
	}
	function g(bool b) public {
		x = 0;
		if (b)
			f();
		else
			f();
		assert(x == 1);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
