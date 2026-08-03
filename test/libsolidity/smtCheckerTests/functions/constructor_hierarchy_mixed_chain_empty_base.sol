contract F {
	uint a;
	constructor() {
		a = 2;
	}
}

contract E is F {}
contract D is E {
	constructor() {
		a = 3;
	}
}
contract C is D {}
contract B is C {
	constructor() {
		assert(a == 3);
		a = 4;
	}
}

contract A is B {
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
