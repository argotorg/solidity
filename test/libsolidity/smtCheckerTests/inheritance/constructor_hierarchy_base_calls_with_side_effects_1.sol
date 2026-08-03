contract A {
	uint public x;
	constructor(uint a) { x = a; }
}

contract B is A {
	constructor(uint b) A(b + f()) {
	}

	function f() internal returns (uint) {
		x = x + 1;
		return x;
	}
}

abstract contract Z is A {
	uint k;
	constructor(uint z) {
		k = z;
	}
}

contract C is Z, B {
	constructor() B(x) Z(x) {
		assert(x == 1);
		assert(k == 0);
		assert(x == k); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (105-112): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nx = 1\nb = 115792089237316195423570985008687907853269984665640564039457584007913129639935\n\nTransaction trace:\nB.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639935)
// Warning 6328: (351-365): CHC: Assertion violation happens here.\nCounterexample:\nk = 0, x = 1\n\nTransaction trace:\nC.constructor()
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
