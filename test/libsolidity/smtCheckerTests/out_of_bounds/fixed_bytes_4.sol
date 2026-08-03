contract C {
	function r(bytes32 x, uint y) public pure {
		x[0]; // safe access
		// Disabled because of Spacer nondeterminism.
		//x[y]; // oob access
	}
}
// ====
// SMTEngine: all
// ----
// Warning 5667: (36-42): Unused function parameter. Remove or comment out the variable name to silence this warning.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
