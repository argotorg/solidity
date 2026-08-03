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
// Warning 6328: (150-164): CHC: Assertion violation happens here.\nCounterexample:\n\nk = 0x2e16\ns = 0x2e15\nr = 0x2297\n\nTransaction trace:\nC.constructor()\nC.f(data) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (168-182): CHC: Assertion violation happens here.\nCounterexample:\n\nk = 0x2e16\ns = 0x2e15\nr = 0x2e16\n\nTransaction trace:\nC.constructor()\nC.f(data) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (186-200): CHC: Assertion violation happens here.\nCounterexample:\n\nk = 0x2e15\ns = 0x2e16\nr = 0x2e17\n\nTransaction trace:\nC.constructor()\nC.f(data) -- counterexample incomplete; parameter name used instead of value
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
