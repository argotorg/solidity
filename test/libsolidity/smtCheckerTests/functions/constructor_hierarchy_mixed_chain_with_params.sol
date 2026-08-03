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
	constructor(uint x) F(x + 1) {
	}
}

contract A is B {
	constructor(uint x) B(x) {
		assert(a == 3);
		assert(a == 4);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (215-220): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\na = 0\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639935\n\nTransaction trace:\nB.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639935)
// Warning 6328: (296-310): CHC: Assertion violation happens here.\nCounterexample:\na = 3\nx = 0\n\nTransaction trace:\nA.constructor(0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
