contract C {

	struct S {
		uint x;
	}
	S s;

	function check() public {
		require(s.x == 0);
		conditional_increment();
		assert(s.x == 1); // should fail;
		assert(s.x == 0); // should hold;
	}

	function conditional_increment() internal {
		if (s.x == 0) {
			return;
		}
		s = S(1);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (123-139): CHC: Assertion violation happens here.\nCounterexample:\ns = {x: 0}\n\nTransaction trace:\nC.constructor()\nState: s = {x: 0}\nC.check()\n    C.conditional_increment() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
