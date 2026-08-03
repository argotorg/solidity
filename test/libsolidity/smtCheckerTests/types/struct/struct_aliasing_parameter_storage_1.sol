contract C {
    struct S {
        mapping(address => uint) innerM;
		uint sum;
    }

	function f(S storage m, address i, uint v) internal {
		m.innerM[i] = v;
		m.sum += v;
	}

	S s;

	constructor(uint amt) {
		f(s, msg.sender, amt);
	}
	function g() public view {
		assert(s.sum == 0); // should hold but no aliasing support means it fails for now
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (270-288): CHC: Assertion violation happens here.\nCounterexample:\ns = {innerM, sum: 8856}\n\nTransaction trace:\nC.constructor(0){ msg.sender: 0x51f0 }\nState: s = {innerM, sum: 8856}\nC.g()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
