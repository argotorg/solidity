interface D {
	function ext(C c) external returns (uint);
}

contract C {
	uint x;
	function s(uint _x) public { x = _x; }
	constructor(D d) {
		uint a = d.ext(this);
		assert(x == 0); // should hold because there's no reentrancy from the constructor
		assert(a == 2); // should fail
	}
}
// ====
// SMTIgnoreCex: yes
// ----
// Warning 6328: (253-267): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\nd = 0\na = 3\n\nTransaction trace:\nC.constructor(0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
