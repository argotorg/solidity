type MyInt is int;
contract C {
    mapping(MyInt => int) m;
	function f(MyInt a) public view {
		assert(m[a] == 0); // should hold
		assert(m[a] != 0); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreInv: yes
// ----
// Warning 6328: (134-151): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
