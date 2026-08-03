contract C {
	uint a;
	constructor(uint x) {
		a = x;
	}
}

abstract contract B is C {
	constructor(uint x) {
		a = x;
	}
}

contract A is B {
	constructor(uint x) C(x + 2) B(x + 1) {
		assert(a == x + 1);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (166-171): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\na = 0\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639934\n\nTransaction trace:\nA.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639934)
// Warning 4984: (175-180): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\na = 0\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639935\n\nTransaction trace:\nA.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639935)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
