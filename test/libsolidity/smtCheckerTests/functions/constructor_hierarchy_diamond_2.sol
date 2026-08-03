contract C {
	uint a;
	constructor(uint x) {
		a = x;
	}
}

abstract contract B1 is C {
	constructor(uint x) {
		a = x;
	}
}

contract B2 is C {
	constructor(uint x) C(x + 2) {
		a = x;
	}
}

contract A is B2, B1 {
	constructor(uint x) B1(x) B2(x) {
		assert(a == x);
		assert(a == x + 1);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (168-173): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\na = 0\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639934\n\nTransaction trace:\nB2.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639934)
// Warning 6328: (270-288): CHC: Assertion violation happens here.\nCounterexample:\na = 0\nx = 0\n\nTransaction trace:\nA.constructor(0)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
