contract C
{
	mapping (uint => uint) map;
	function f(uint x) public {
		map[2] = x;
		map[2] = 3;
		assert(x != map[2]);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (101-120): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 3\n\nTransaction trace:\nC.constructor()\nC.f(3)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
