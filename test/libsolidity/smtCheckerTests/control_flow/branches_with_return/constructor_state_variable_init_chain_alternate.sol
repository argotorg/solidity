contract A {
	uint x = 1;
}

contract B is A {
	constructor(int a) {
		if (a > 0) {
			x = 2;
			return;
		}
		x = 3;
	}
}

abstract contract C is B {
}

contract D is C {
	constructor(int a) B(a) {
		assert(a > 0 || x == 3); // should hold
		assert(a <= 0 || x == 2); // should hold
		assert(x == 1); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (286-300): CHC: Assertion violation happens here.\nCounterexample:\nx = 2\na = 1\n\nTransaction trace:\nD.constructor(1)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
