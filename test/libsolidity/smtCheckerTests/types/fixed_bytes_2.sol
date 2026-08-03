contract C
{
	bytes32 x;
	function f(bytes8 y) public view {
		assert(x == g());
		assert(x != y);
	}
	function g() public view returns (bytes32) {
		return x;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (83-97): CHC: Assertion violation happens here.\nCounterexample:\nx = 0x0\ny = 0x0\n\nTransaction trace:\nC.constructor()\nState: x = 0x0\nC.f(0x0)\n    C.g() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
