contract C {
	constructor() payable {
		require(msg.value > 100);
	}
	function f() public view {
		assert(address(this).balance > 100); // should hold
		assert(address(this).balance > 200); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (153-188): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor(){ msg.value: 101 }\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
