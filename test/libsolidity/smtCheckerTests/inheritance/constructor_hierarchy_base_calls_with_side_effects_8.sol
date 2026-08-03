contract A {
	uint public x;
	constructor(uint) {}

	function f() internal returns (uint) {
		x = x + 1;
		return x;
	}
}

contract C is A {
	constructor() A(f()) {
		assert(x == 1);
		assert(x == 0); // should fail
		assert(x > 2000); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (185-199): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\n\nTransaction trace:\nC.constructor()
// Warning 6328: (218-234): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\n\nTransaction trace:\nC.constructor()
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
