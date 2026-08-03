contract D {
	uint x;
}

contract C {
	function f() public {
		D d1 = new D();
		D d2 = new D();

		assert(d1 != d2); // should hold in ext calls trusted mode
		assert(address(this) != address(d1)); // should hold in ext calls trusted mode
		assert(address(this) != address(d2)); // should hold in ext calls trusted mode
	}
}
// ====
// SMTEngine: all
// SMTExtCalls: trusted
// ----
// Warning 9170: (107-115): Comparison of variables of contract type is deprecated and scheduled for removal. Use an explicit cast to address type and compare the addresses instead.
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
