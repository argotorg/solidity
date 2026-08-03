contract C {
	function abiDecodeSimple(bytes memory b1, bytes memory b2) public pure {
		(uint x, uint y) = abi.decode(b1, (uint, uint));
		(uint z, uint w) = abi.decode(b1, (uint, uint));
		assert(x == z);
		assert(x == y); // should fail
		assert(y == w);
		assert(z == w); // should fail

		(uint a, uint b, bool c) = abi.decode(b1, (uint, uint, bool));
		assert(a == x); // should fail
		assert(b == y); // should fail
		assert(c); // should fail

		(uint k, uint l) = abi.decode(b2, (uint, uint));
		assert(k == x); // should fail
		assert(l == y); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (209-223): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 8855\ny = 8856\nz = 8855\nw = 8856\na = 0\nb = 0\nc = false\nk = 0\nl = 0\n\nTransaction trace:\nC.constructor()\nC.abiDecodeSimple(b1, b2) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (260-274): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 11798\ny = 11797\nz = 11798\nw = 11797\na = 0\nb = 0\nc = false\nk = 0\nl = 0\n\nTransaction trace:\nC.constructor()\nC.abiDecodeSimple(b1, b2) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (359-373): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 11798\ny = 11797\nz = 11798\nw = 11797\na = 8365\nb = 7\nc = false\nk = 0\nl = 0\n\nTransaction trace:\nC.constructor()\nC.abiDecodeSimple(b1, b2) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (392-406): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 8855\ny = 8856\nz = 8855\nw = 8856\na = 8856\nb = 8857\nc = false\nk = 0\nl = 0\n\nTransaction trace:\nC.constructor()\nC.abiDecodeSimple(b1, b2) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (425-434): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 11798\ny = 11799\nz = 11798\nw = 11799\na = 11797\nb = 11800\nc = false\nk = 0\nl = 0\n\nTransaction trace:\nC.constructor()\nC.abiDecodeSimple(b1, b2) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (505-519): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 11798\ny = 11799\nz = 11798\nw = 11799\na = 11797\nb = 8365\nc = false\nk = 8689\nl = 5\n\nTransaction trace:\nC.constructor()\nC.abiDecodeSimple(b1, b2) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (538-552): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 11798\ny = 11799\nz = 11798\nw = 11799\na = 11797\nb = 8687\nc = false\nk = 8365\nl = 10450\n\nTransaction trace:\nC.constructor()\nC.abiDecodeSimple(b1, b2) -- counterexample incomplete; parameter name used instead of value
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
