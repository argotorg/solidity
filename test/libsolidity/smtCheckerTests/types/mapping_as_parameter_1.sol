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
// Warning 6328: (256-273): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0\nb = 8366\n\nTransaction trace:\nc.constructor()\nc.g(0, 8366)\n    c.f(map, 0, 8366) -- counterexample incomplete; parameter name used instead of value -- internal call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
