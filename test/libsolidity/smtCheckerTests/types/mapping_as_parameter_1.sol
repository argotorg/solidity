contract c {
	mapping(uint => uint) x;
	function f(mapping(uint => uint) storage map, uint index, uint value) internal {
		map[index] = value;
	}
	function g(uint a, uint b) public {
		f(x, a, b);
		// False positive since aliasing is not yet supported.
		assert(x[a] == b);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (256-273): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0\nb = 0\n\nTransaction trace:\nc.constructor()\nc.g(0, 0)\n    c.f(map, 0, 0) -- counterexample incomplete; parameter name used instead of value -- internal call
