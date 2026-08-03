contract C {
	uint[] b;

	function f() public {
		require(b.length == 0);
		b.push() = 1;
		assert(b[0] == 1);
	}

	function g() public {
		b.push() = 1;
		assert(b[b.length - 1] == 1);
		// Fails
		assert(b[b.length - 1] == 100);
	}

}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTIgnoreOS: macos
// ----
// Warning 6328: (199-229): CHC: Assertion violation happens here.\nCounterexample:\nb = [1]\n\nTransaction trace:\nC.constructor()\nState: b = []\nC.g()
// Info 1391: CHC: 7 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
