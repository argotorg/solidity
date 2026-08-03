contract C {
	type T is uint;
}
contract D {
	function f(C.T x) internal pure returns(uint) {
		return C.T.unwrap(x);
	}
	function g(uint x) internal pure returns(C.T) {
		return C.T.wrap(x);
	}
	function h(uint x) internal pure returns(uint) {
		return f(g(x));
	}
	function i(C.T x) internal pure returns(C.T) {
		return g(f(x));
	}

	function m() public pure {
		assert(f(C.T.wrap(0x42)) == 0x42);
		assert(f(C.T.wrap(0x42)) == 0x43); // should fail
		assert(C.T.unwrap(g(0x42)) == 0x42);
		assert(C.T.unwrap(g(0x42)) == 0x43); // should fail
		assert(h(0x42) == 0x42);
		assert(h(0x42) == 0x43); // should fail
		assert(C.T.unwrap(i(C.T.wrap(0x42))) == 0x42);
		assert(C.T.unwrap(i(C.T.wrap(0x42))) == 0x43); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (403-436): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nD.constructor()\nD.m()\n    D.f(66) -- internal call\n    D.f(66) -- internal call
// Warning 6328: (494-529): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nD.constructor()\nD.m()\n    D.f(66) -- internal call\n    D.f(66) -- internal call\n    D.g(66) -- internal call\n    D.g(66) -- internal call
// Warning 6328: (575-598): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nD.constructor()\nD.m()\n    D.f(66) -- internal call\n    D.f(66) -- internal call\n    D.g(66) -- internal call\n    D.g(66) -- internal call\n    D.h(66) -- internal call\n        D.g(66) -- internal call\n        D.f(66) -- internal call\n    D.h(66) -- internal call\n        D.g(66) -- internal call\n        D.f(66) -- internal call
// Warning 6328: (666-711): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nD.constructor()\nD.m()\n    D.f(66) -- internal call\n    D.f(66) -- internal call\n    D.g(66) -- internal call\n    D.g(66) -- internal call\n    D.h(66) -- internal call\n        D.g(66) -- internal call\n        D.f(66) -- internal call\n    D.h(66) -- internal call\n        D.g(66) -- internal call\n        D.f(66) -- internal call\n    D.i(66) -- internal call\n        D.f(66) -- internal call\n        D.g(66) -- internal call\n    D.i(66) -- internal call\n        D.f(66) -- internal call\n        D.g(66) -- internal call
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
