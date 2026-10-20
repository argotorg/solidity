contract C {
	uint x = 5;

	constructor(uint a, uint b) {
		assert(x == 5);
		x = a + b;
	}

	function f(uint y) view public {
		assert(y == x);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (82-87): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\nx = 5\na = 115792089237316195423570985008687907853269984665640564039457584007913129639935\nb = 1\n\nTransaction trace:\nC.constructor(115792089237316195423570985008687907853269984665640564039457584007913129639935, 1)
// Warning 6328: (129-143): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\ny = 0\n\nTransaction trace:\nC.constructor(0, 1)\nState: x = 1\nC.f(0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
