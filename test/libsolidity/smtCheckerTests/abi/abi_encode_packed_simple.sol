contract C {
	function abiencodePackedSimple(bool t, uint x, uint y, uint z, uint[] memory a, uint[] memory b) public pure {
		require(x == y);
		bytes memory b1 = abi.encodePacked(x, z, a);
		bytes memory b2 = abi.encodePacked(y, z, a);
		assert(b1.length == b2.length);

		bytes memory b3 = abi.encodePacked(y, z, b);
		assert(b1.length == b3.length); // should fail

		bytes memory b4 = abi.encodePacked(t, z, a);
		assert(b1.length == b4.length); // should fail

		bytes memory b5 = abi.encodePacked(y, y, y, y, a, a, a);
		assert(b1.length != b5.length); // should fail
		assert(b1.length == b5.length); // should fail

		// Commented out because of nondeterminism in Spacer in Z3 4.8.9
		//bytes memory b6 = abi.encode(x, z, a);
		//assert(b1.length == b6.length); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (322-352): CHC: Assertion violation happens here.\nCounterexample:\n\nt = false\nx = 0\ny = 0\nz = 0\nb4 = []\nb5 = []\n\nTransaction trace:\nC.constructor()\nC.abiencodePackedSimple(false, 0, 0, 0, a, b) -- counterexample incomplete; parameter name used instead of value
// Warning 6328: (419-449): CHC: Assertion violation happens here.
// Warning 6328: (528-558): CHC: Assertion violation happens here.
// Warning 6328: (577-607): CHC: Assertion violation happens here.
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
