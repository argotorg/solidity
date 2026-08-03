contract C {
	function oneArg(bytes memory a) public pure {
		bytes memory concat = bytes.concat(a);
		assert(keccak256(a) == keccak256(concat));
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
