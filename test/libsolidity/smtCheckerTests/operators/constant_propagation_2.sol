contract C {
	uint constant x = 7;
	uint constant y = 3;
	uint constant z = x / y;

	function f() public pure {
		assert(z == 2);
		assert(z == x / 3);
		assert(z == 7 / y);
		assert(z * 3 != 7);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
