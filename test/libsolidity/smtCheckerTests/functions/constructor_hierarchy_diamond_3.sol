contract C {
	uint a;
	constructor(uint x) {
		a = x;
	}
}

abstract contract B1 is C {
	uint b1;
	constructor(uint x) {
		b1 = x + a;
	}
}

contract B2 is C {
	uint b2;
	constructor(uint x) C(x + 2) {
		b2 = x + a;
	}
}

contract A is B2, B1 {
	constructor(uint x) B2(x) B1(x) {
		assert(b1 == b2);
		assert(b1 != b2);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (193-198): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nb2 = 0, a = 0\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639934\n\nTransaction trace:\nB2.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639934)
// Warning 4984: (209-214): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nb2 = 0, a = 115792089237316195423570985008687907853269984665640564039457584007913129639935\nx = 115792089237316195423570985008687907853269984665640564039457584007913129639933\n\nTransaction trace:\nB2.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639933)
// Warning 6328: (302-318): CHC: Assertion violation happens here.\nCounterexample:\nb1 = 2, b2 = 2, a = 2\nx = 0\n\nTransaction trace:\nA.constructor(0)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
