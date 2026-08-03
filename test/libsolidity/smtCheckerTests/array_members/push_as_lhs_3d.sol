contract C {
	uint[][][] c;

	function f() public {
		require(c.length == 0);
		c.push().push().push() = 2;
		assert(c.length == 1);
		assert(c[0].length == 1);
		assert(c[0][0].length == 1);
		assert(c[0][0][0] == 2);
	}

	function g() public {
		c.push().push().push() = 2;
		uint length1 = c.length;
		uint length2 = c[length1 - 1].length;
		uint length3 = c[length1 - 1][length2 - 1].length;
		assert(length1 > 0);
		assert(length2 == 1);
		assert(length3 == 1);
		assert(c[length1 - 1][length2 - 1][length3 - 1] == 2);
		// Fails
		assert(c[length1 - 1][length2 - 1][length3 - 1] == 200);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (537-592): CHC: Assertion violation happens here.\nCounterexample:\nc = [[[2]]]\nlength1 = 1\nlength2 = 1\nlength3 = 1\n\nTransaction trace:\nC.constructor()\nState: c = []\nC.g()
// Info 1391: CHC: 32 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
