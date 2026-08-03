contract C {
	uint x;
	function f(address a) public {
		(bool s, bytes memory data) = a.call("");
		assert(x == 0); // should hold
	}
}
// ====
// SMTEngine: all
// SMTIgnoreInv: yes
// ----
// Warning 2072: (57-63): Unused local variable.
// Warning 2072: (65-82): Unused local variable.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
