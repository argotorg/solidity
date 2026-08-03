contract C {
    struct S {
        mapping(address => uint) innerM;
		uint sum;
    }

	struct T {
		uint x;
		S s;
	}

	function f(T storage m, address i, uint v) internal {
		m.s.innerM[i] = v;
		m.s.sum += v;
	}

	T t;

	constructor(uint amt) {
		f(t, msg.sender, amt);
	}
	function g() public view {
		assert(t.s.sum == 0); // should hold but no aliasing support means it fails for now
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (307-327): CHC: Assertion violation happens here.\nCounterexample:\nt = {x: 11, s: {innerM, sum: 8856}}\n\nTransaction trace:\nC.constructor(0){ msg.sender: 0x6532 }\nState: t = {x: 11, s: {innerM, sum: 8856}}\nC.g()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
