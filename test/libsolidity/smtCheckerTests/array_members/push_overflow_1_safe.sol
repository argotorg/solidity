contract C {
	uint256[] x;
	constructor() { x.push(42); }
	function f() public {
		x.push(23);
		assert(x[0] == 42 || x[0] == 23);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreInv: yes
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
