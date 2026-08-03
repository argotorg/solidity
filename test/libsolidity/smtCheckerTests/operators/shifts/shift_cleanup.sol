contract C {
	function f() public pure returns (uint16 x) {
		unchecked {
			x = 0xffff;
			x += 32;
			x = x << 8;
			x = x >> 16;
		}
		assert(x == 0);
		// Fails because x = 0.
		assert(x == 10);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (182-197): CHC: Assertion violation happens here.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
