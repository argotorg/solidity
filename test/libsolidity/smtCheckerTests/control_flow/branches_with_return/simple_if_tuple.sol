contract C {

	uint x;
	uint y;

	function check() public {
		require(x == 0);
		require(y == 0);
		conditional_increment();
		assert(x == 0); // should fail;
		assert(x == 1); // should fail;
		assert(x == 2); // should hold;
	}

	function conditional_increment() internal {
		if (x == 0) {
			(x,y) = (2,2);
			return;
		}
		(x,y) = (1,1);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (127-141): CHC: Assertion violation happens here.\nCounterexample:\nx = 2, y = 2\n\nTransaction trace:\nC.constructor()\nState: x = 0, y = 0\nC.check()\n    C.conditional_increment() -- internal call
// Warning 6328: (161-175): CHC: Assertion violation happens here.\nCounterexample:\nx = 2, y = 2\n\nTransaction trace:\nC.constructor()\nState: x = 0, y = 0\nC.check()\n    C.conditional_increment() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
