contract C {
    function g() public pure returns (bytes32 val) { return "abc"; }
    function f1() public pure returns (bytes32 val) { return g(); }

	function a() public pure {
		assert(f1() == "abc");
		assert(f1() == "cde");
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (206-227): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.a()\n    C.f1() -- internal call\n        C.g() -- internal call\n    C.f1() -- internal call\n        C.g() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
