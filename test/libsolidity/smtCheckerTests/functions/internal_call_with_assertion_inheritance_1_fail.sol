contract A {
	uint x;
	function f() internal {
		assert(x == 2);
		--x;
	}
}

contract C is A {
	constructor() {
		assert(x == 1);
		++x;
		f();
		assert(x == 1);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (49-63): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\n\nTransaction trace:\nC.constructor()
// Warning 6328: (115-129): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\n\nTransaction trace:\nC.constructor()
// Warning 6328: (147-161): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\n\nTransaction trace:\nC.constructor()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
