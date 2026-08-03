contract C
{
	function f(uint _x) public pure returns (uint) {
		return _x;
	}
}

contract D
{
	C c;
	function g(uint _y) public view {
		uint z = c.f(_y);
		assert(z == _y);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (158-173): CHC: Assertion violation happens here.\nCounterexample:\nc = 0\n_y = 0\nz = 1\n\nTransaction trace:\nD.constructor()\nState: c = 0\nD.g(0)\n    c.f(_y) -- untrusted external call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
