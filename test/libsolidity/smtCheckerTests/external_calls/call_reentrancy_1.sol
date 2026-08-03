contract C {
	uint x;
	function s(uint _x) public {
		x = _x;
	}
	function f(address a) public {
		(bool s, bytes memory data) = a.call("");
		assert(x == 0); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 2519: (100-106): This declaration shadows an existing declaration.
// Warning 2072: (100-106): Unused local variable.
// Warning 2072: (108-125): Unused local variable.
// Warning 6328: (143-157): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\na = 0x0\ns = false\ndata = []\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.s(1)\nState: x = 1\nC.f(0x0)\n    a.call("") -- untrusted external call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
