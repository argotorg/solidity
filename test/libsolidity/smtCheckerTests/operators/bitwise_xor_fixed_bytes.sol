contract Simp {
	function f3() public pure returns (bytes1) {
		bytes memory y = "def";
		assert(y[0] ^ "e" != bytes1(0)); // should hold
		assert(y[1] ^ "e" != bytes1(0)); // should fail
		return y[0];
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (140-171): CHC: Assertion violation happens here.
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
