contract A {
	uint x;
	constructor (uint y) { assert(x == 0); x = y; }
}

contract B is A {
	constructor () A(2) { assert(x == 2); }
}

contract C is B {
	function f() public view {
		assert(x == 2);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreInv: yes
// SMTSolvers: z3
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
