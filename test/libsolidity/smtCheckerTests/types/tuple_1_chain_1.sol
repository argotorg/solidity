contract C {
	function i() public pure returns (uint d) {
		if (0==0)
			(d) = 13;
		assert(d == 13);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (64-68): BMC: Condition is always true.
