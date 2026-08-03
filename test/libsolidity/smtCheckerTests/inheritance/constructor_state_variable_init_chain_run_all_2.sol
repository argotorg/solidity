contract C {
	uint a;
	constructor(uint x) {
		a = x;
	}
}

abstract contract B is C {
	uint b;
	constructor(uint x) {
		b = x + 10;
	}
}

contract A is B {
	constructor(uint x) B(x) C(x + 2) {
		assert(a == x + 2);
		assert(b == x + 10);
		assert(b == x + 5);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (125-131): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nb = 0, a = 115792089237316195423570985008687907853269984665640564039457584007913129639928\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639926\n\nTransaction trace:\nA.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639926)
// Warning 4984: (185-190): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nb = 0, a = 0\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639934\n\nTransaction trace:\nA.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639934)
// Warning 6328: (241-259): CHC: Assertion violation happens here.\nCounterexample:\nb = 10, a = 2\nx = 0\n\nTransaction trace:\nA.constructor(0)
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
