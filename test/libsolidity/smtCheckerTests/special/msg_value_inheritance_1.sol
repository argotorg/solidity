contract A {
	uint public x = msg.value;
	constructor() payable {
		assert(x == 0); // should fail, A can be constructed with any msg.value
	}
}

contract C is A {
	uint public v = msg.value;
	constructor() A() {
		assert(v == 0); // should hold
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (68-82): CHC: Assertion violation happens here.\nCounterexample:\nx = 115792089237316195423570985008687907853269984665640564039457584007913129628138\n\nTransaction trace:\nA.constructor(){ msg.value: 115792089237316195423570985008687907853269984665640564039457584007913129628138 }
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
