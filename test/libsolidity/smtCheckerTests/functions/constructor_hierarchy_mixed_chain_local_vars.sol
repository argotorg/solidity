contract F {
	uint a;
	constructor() {
		uint f = 2;
		a = f;
	}
}

contract E is F {}
contract D is E {
	constructor() {
		uint d = 3;
		a = d;
	}
}
contract C is D {}
contract B is C {
	constructor() {
		uint b = 4;
		a = b;
	}
}

contract A is B {
	constructor(uint x) {
		uint a1 = 4;
		uint a2 = 5;
		assert(a == a1);
		assert(a == a2);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 5667: (264-270): Unused function parameter. Remove or comment out the variable name to silence this warning.
// Warning 6328: (325-340): CHC: Assertion violation happens here.\nCounterexample:\na = 4\nx = 0\na1 = 4\na2 = 5\n\nTransaction trace:\nA.constructor(0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
