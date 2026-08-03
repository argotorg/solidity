contract C {
	function g(uint i) public {
		require(address(this).balance == 100);
		// if called address is same as this, don't do anything with the value stuff
		// or fix the receiving end
		this.h{value: i}();
		uint x = address(this).balance;
		assert(x == 100); // should hold
		assert(address(this).balance == 100); // should hold
		assert(address(this).balance == 90); // should fail
	}

	function h() external payable {}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (340-375): CHC: Assertion violation happens here.\nCounterexample:\n\ni = 0\nx = 100\n\nTransaction trace:\nC.constructor()\nC.g(0)\n    C.h() -- trusted external call
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
