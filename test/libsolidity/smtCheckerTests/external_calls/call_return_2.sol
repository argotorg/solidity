contract C {
	uint x;
	function f(address a) public {
		(bool s, bytes memory data) = a.call("");
		assert(data.length > 10); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 2072: (57-63): Unused local variable.
// Warning 6328: (100-124): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\na = 0x0\ns = false\ndata = [0x0a, 0x0a, 0x2e, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a]\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x0)\n    a.call("") -- untrusted external call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
