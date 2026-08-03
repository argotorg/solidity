uint constant A = 42;
contract C {
	uint[] data;
	function f(uint x, uint[] calldata input) public view returns (uint, uint) {
		(uint a, uint[] calldata b) = fun(input, data);
		return (a, b.length + x + A);
	}
}
function fun(uint[] calldata _x, uint[] storage _y) view  returns (uint, uint[] calldata) {
	return (_y[0], _x);
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (190-202): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\ndata = []\nx = 1\n = 0\n = 0\na = 0\n\nTransaction trace:\nC.constructor()\nState: data = []\nC.f(1, input) -- counterexample incomplete; parameter name used instead of value\n    fun(_x, []) -- counterexample incomplete; parameter name used instead of value -- internal call
// Warning 4984: (190-206): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\ndata = []\nx = 0\n = 0\n = 0\na = 0\n\nTransaction trace:\nC.constructor()\nState: data = []\nC.f(0, input) -- counterexample incomplete; parameter name used instead of value\n    fun(_x, []) -- counterexample incomplete; parameter name used instead of value -- internal call
// Warning 6368: (315-320): CHC: Out of bounds access happens here.\nCounterexample:\ndata = []\nx = 0\n = 0\n = 0\n\nTransaction trace:\nC.constructor()\nState: data = []\nC.f(0, input) -- counterexample incomplete; parameter name used instead of value\n    fun(_x, []) -- counterexample incomplete; parameter name used instead of value -- internal call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
