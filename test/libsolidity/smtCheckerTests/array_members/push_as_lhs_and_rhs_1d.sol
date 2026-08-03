contract C {
	uint[] b;
	function f() public {
		b.push() = b.push();
		uint length = b.length;
		assert(length >= 2);
		assert(b[length - 1] == 0);
		assert(b[length - 1] == b[length - 2]);
		// Fails
		assert(b[length - 1] == 1);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreOS: macos
// ----
// Warning 6328: (204-230): CHC: Assertion violation happens here.\nCounterexample:\nb = [0, 0]\nlength = 2\n\nTransaction trace:\nC.constructor()\nState: b = []\nC.f()
// Info 1391: CHC: 11 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
