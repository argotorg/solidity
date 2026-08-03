contract F {
	uint a;
	constructor(uint x) {
		a = x;
	}
}

abstract contract E is F {}
abstract contract D is E {
	constructor() {
		a = 3;
	}
}
abstract contract C is D {}
contract B is C {
	constructor() F(1) {
		assert(a == 3);
		assert(a == 2);
	}
}

contract A is B {
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (234-248): CHC: Assertion violation happens here.\nCounterexample:\na = 3\n\nTransaction trace:\nB.constructor()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
