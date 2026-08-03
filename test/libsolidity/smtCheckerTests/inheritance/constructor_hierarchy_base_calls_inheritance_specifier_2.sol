contract A {
	uint public x;
	constructor(uint a) { x = a; }
}

contract B is A(9) {
	constructor(uint b) {
		x += b;
	}

	function f() internal returns (uint) {
		x = x + 1;
		return x;
	}

	function g() internal returns (uint) {
		x = 42;
		return x;
	}
}

contract Z is B {
	constructor(uint z) B(z + f()) {
	}
}

contract C is Z(5) {
	constructor() {
		assert(x == 15);
		assert(x > 90); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (110-116): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nx = 9\nb = 115792089237316195423570985008687907853269984665640564039457584007913129639927\n\nTransaction trace:\nB.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639927)
// Warning 4984: (300-307): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nx = 1\nz = 115792089237316195423570985008687907853269984665640564039457584007913129639935\n\nTransaction trace:\nZ.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639935)
// Warning 6328: (376-390): CHC: Assertion violation happens here.\nCounterexample:\nx = 15\n\nTransaction trace:\nC.constructor()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
