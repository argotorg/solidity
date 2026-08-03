contract D {
	uint x;
}

contract C {
	uint y;
	function g() public {
		D d = new D();
		assert(y == 0); // should hold
	}
}
// ====
// SMTEngine: all
// SMTExtCalls: trusted
// ----
// Warning 2072: (72-75): Unused local variable.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
