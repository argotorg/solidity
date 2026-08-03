contract C {
	function f() public pure {
		bytes memory x = hex"0123";
		assert(x.length == 2);
	}
	function g() public pure {
		bytes memory x = bytes(hex"0123");
		assert(x.length == 2);
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
