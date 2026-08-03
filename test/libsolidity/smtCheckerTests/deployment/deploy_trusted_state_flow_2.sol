contract D {
	uint x;
	function f() public view returns (uint) { return x; }
}

contract C {
	D d;
	constructor() {
		d = new D();
		assert(d.f() == 0); // should hold
	}
	function g() public view {
		assert(d.f() == 0); // should hold
	}
}
// ====
// SMTEngine: all
// SMTExtCalls: trusted
// ----
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
