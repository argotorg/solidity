contract C {
	function abiEncodeStringLiteral(bytes4 sel) public pure {
		bytes memory b1 = abi.encodeWithSelector("");
		require(sel == "");
		bytes memory b2 = abi.encodeWithSelector(sel);
		assert(b1.length == b2.length); // should hold
	}
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
