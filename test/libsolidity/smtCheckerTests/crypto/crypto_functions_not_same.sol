contract C {
	function f(bytes memory data) public pure {
		bytes32 k = keccak256(data);
		fi(data, k);
	}
	function fi(bytes memory data, bytes32 k) internal pure {
		bytes32 h = sha256(data);
		assert(h == k);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (196-210): CHC: Assertion violation happens here.\nCounterexample:\n\nh = 0x2298\n\nTransaction trace:\nC.constructor()\nC.f(data) -- counterexample incomplete; parameter name used instead of value\n    C.fi(data, 0x2297) -- counterexample incomplete; parameter name used instead of value -- internal call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
