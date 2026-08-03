contract C
{
	modifier m(uint x) {
		require(x == 2);
		_;
		return;
	}

	modifier n(uint x) {
		require(x == 3);
		_;
	}

	function f(uint x) m(x) n(x) public pure {
		assert(x == 3);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
