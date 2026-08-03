contract B {
	int x;
	constructor(int b) {
		if (b > 0) {
			x = 1;
			return;
		}
		else {
			x = 2;
			return;
		}
		x = 3; // dead code
	}
}

contract C is B {
	constructor(int a) B(a) {
		assert(a > 0 || x == 2); // should hold
		assert(a <= 0 || x == 1); // should hold
		assert(x == 3); // should fail
		assert(x == 2); // should fail
		assert(x == 1); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 5740: (119-124): Unreachable code.
// Warning 6328: (277-291): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\na = 1\n\nTransaction trace:\nC.constructor(1)
// Warning 6328: (310-324): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\na = 1\n\nTransaction trace:\nC.constructor(1)
// Warning 6328: (343-357): CHC: Assertion violation happens here.\nCounterexample:\nx = 2\na = 0\n\nTransaction trace:\nC.constructor(0)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
