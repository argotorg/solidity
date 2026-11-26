contract C {
	function f(bytes memory data) public pure {
		bytes32 k = keccak256(data);
		bytes32 s = sha256(data);
		bytes32 r = ripemd160(data);
		assert(k == s);
		assert(s == r);
		assert(r == k);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (150-164): CHC: Assertion violation happens here.\nCounterexample:\n\nk = 0x20ad\ns = 0x20ae\nr = 0x2297\n\nTransaction trace:\nC.constructor()\nC.f(data) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (168-182): CHC: Assertion violation happens here.\nCounterexample:\n\nk = 0x2299\ns = 0x2298\nr = 0x2297\n\nTransaction trace:\nC.constructor()\nC.f(data) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (186-200): CHC: Assertion violation happens here.\nCounterexample:\n\nk = 0x20ad\ns = 0x20af\nr = 0x20ae\n\nTransaction trace:\nC.constructor()\nC.f(data) -- counterexample incomplete; parameter name used instead of value
