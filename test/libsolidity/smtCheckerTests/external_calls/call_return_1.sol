contract C {
	uint x;
	function f(address a) public {
		(bool s, bytes memory data) = a.call("");
		assert(s); // should fail
		assert(!s); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 2072: (65-82): Unused local variable.
// Warning 6328: (100-109): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\na = 0x0\ns = false\ndata = []\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x0)\n    a.call("") -- untrusted external call
// Warning 6328: (128-138): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\na = 0x0\ns = true\ndata = []\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x0)\n    a.call("") -- untrusted external call
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
