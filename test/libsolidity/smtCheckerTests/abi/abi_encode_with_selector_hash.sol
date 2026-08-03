contract C {
	function abiEncodeHash(bytes4 sel, uint a, uint b) public pure {
		require(a == b);
		bytes memory b1 = abi.encodeWithSelector(sel, a, a, a, a);
		bytes memory b2 = abi.encodeWithSelector(sel, b, a, b, a);
		// Disabled because of OSX nondeterminism
		//assert(keccak256(b1) == keccak256(b2));

		bytes memory b3 = abi.encodeWithSelector(0xcafecafe, a, a, a, a);
		assert(keccak256(b1) == keccak256(b3)); // should fail
		assert(keccak256(b1) != keccak256(b3)); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 2072: (161-176): Unused local variable.
// Warning 6328: (379-417): CHC: Assertion violation happens here.\nCounterexample:\n\nsel = 0x0\na = 0\nb = 0\n\nTransaction trace:\nC.constructor()\nC.abiEncodeHash(0x0, 0, 0)
// Warning 6328: (436-474): CHC: Assertion violation happens here.\nCounterexample:\n\nsel = 0x0\na = 0\nb = 0\n\nTransaction trace:\nC.constructor()\nC.abiEncodeHash(0x0, 0, 0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
