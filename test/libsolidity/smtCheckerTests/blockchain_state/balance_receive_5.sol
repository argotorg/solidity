contract C {
	uint sum = msg.value;
	function f() public payable {
		sum += msg.value;
	}
	function inv() public view {
		assert(address(this).balance == sum); // should fail
		assert(address(this).balance >= sum); // should hold
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (122-158): CHC: Assertion violation happens here.\nCounterexample:\nsum = 0\n\nTransaction trace:\nC.constructor()\nState: sum = 0\nC.inv()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
