interface I {
	function f() external;
}

contract C {
	function g(I _i) public payable {
		uint x = address(this).balance;
		_i.f();
		assert(x == address(this).balance); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTIgnoreOS: macos
// ----
// Warning 6328: (135-169): CHC: Assertion violation happens here.\nCounterexample:\n\n_i = 0\nx = 1918\n\nTransaction trace:\nC.constructor()\nC.g(0){ msg.value: 1581 }\n    _i.f() -- untrusted external call, synthesized as:\n        C.g(0){ msg.value: 20 } -- reentrant call\n            _i.f() -- untrusted external call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
