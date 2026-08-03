contract C {
	function f() public pure {
		bytes4 x = 0x01020304;
		bytes1 b = x[3];
		assert(b == b[0]);
		assert(b == b[0][0]);
		assert(b == b[0][0][0][0][0][0][0][0][0][0][0]);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 18 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
