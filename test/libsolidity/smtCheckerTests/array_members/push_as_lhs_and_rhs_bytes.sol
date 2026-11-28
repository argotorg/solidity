contract C {
	bytes b;
	function f() public {
		b.push() = b.push();
		uint length = b.length;
		assert(length >= 2);
		assert(b[length - 1] == 0);
		assert(b[length - 1] == b[length - 2]);
		// Fails
		assert(b[length - 1] == bytes1(uint8(1)));
	}
}
// ====
// SMTEngine: chc
// SMTIgnoreOS: macos
// ----
// Warning 6328: (203-244): CHC: Assertion violation happens here.\nCounterexample:\nb = [0x0, 0x0]\nlength = 2\n\nTransaction trace:\nC.constructor()\nState: b = []\nC.f()
// Info 1391: CHC: 11 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
