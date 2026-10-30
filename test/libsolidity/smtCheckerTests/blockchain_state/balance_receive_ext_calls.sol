interface I {
	function ext() external;
}

contract C {
	function f(I _i) public {
		uint x = address(this).balance;
		_i.ext();
		assert(address(this).balance == x); // should fail
		assert(address(this).balance >= x); // should hold
	}
}
// ====
// SMTEngine: chc
// SMTIgnoreOS: macos
// ----
// Warning 6328: (131-165): CHC: Assertion violation happens here.\nCounterexample:\n\n_i = 0\nx = 1654\n\nTransaction trace:\nC.constructor()\nC.f(0)\n    _i.ext() -- untrusted external call, synthesized as:\n        C.f(0) -- reentrant call\n            _i.ext() -- untrusted external call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
