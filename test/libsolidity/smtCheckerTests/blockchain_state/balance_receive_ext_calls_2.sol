contract C {
	function f(address _a) public {
		uint x = address(this).balance;
		_a.call("");
		assert(address(this).balance == x); // should fail
		assert(address(this).balance >= x); // should hold
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTIgnoreInv: yes
// ----
// Warning 9302: (82-93): Return value of low-level calls not used.
// Warning 6328: (97-131): CHC: Assertion violation happens here.\nCounterexample:\n\n_a = 0x0\nx = 38\n\nTransaction trace:\nC.constructor()\nC.f(0x0)\n    _a.call("") -- untrusted external call, synthesized as:\n        C.f(0x0) -- reentrant call\n            _a.call("") -- untrusted external call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
