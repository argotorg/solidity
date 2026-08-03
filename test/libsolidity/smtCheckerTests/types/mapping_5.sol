contract C
{
	mapping (address => uint) map;
	function f(address a, uint x) public view {
		assert(x != map[a]);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (92-111): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x0\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(0x0, 0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
