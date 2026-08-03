contract C {
	uint constant DEPOSIT_CONTRACT_TREE_DEPTH = 32;
	uint constant MAX_DEPOSIT_COUNT = 2**DEPOSIT_CONTRACT_TREE_DEPTH - 1;
	function f() public pure {
		assert(DEPOSIT_CONTRACT_TREE_DEPTH == 32);
		assert(MAX_DEPOSIT_COUNT == 4294967295);
		assert(MAX_DEPOSIT_COUNT == 2); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (251-281): CHC: Assertion violation happens here.\nCounterexample:\nDEPOSIT_CONTRACT_TREE_DEPTH = 32, MAX_DEPOSIT_COUNT = 4294967295\n\nTransaction trace:\nC.constructor()\nState: DEPOSIT_CONTRACT_TREE_DEPTH = 32, MAX_DEPOSIT_COUNT = 4294967295\nC.f()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
