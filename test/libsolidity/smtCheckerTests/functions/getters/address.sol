contract C {
	address public x;
	address payable public y;

	function f() public view {
		address a = this.x();
		address b = this.y();
		assert(a == x); // should hold
		assert(a == address(this)); // should fail
		assert(b == y); // should hold
		assert(y == address(this)); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (171-197): CHC: Assertion violation happens here.\nCounterexample:\nx = 0x0, y = 0x0\na = 0x0\nb = 0x0\n\nTransaction trace:\nC.constructor()\nState: x = 0x0, y = 0x0\nC.f()
// Warning 6328: (249-275): CHC: Assertion violation happens here.\nCounterexample:\nx = 0x0, y = 0x0\na = 0x0\nb = 0x0\n\nTransaction trace:\nC.constructor()\nState: x = 0x0, y = 0x0\nC.f()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
