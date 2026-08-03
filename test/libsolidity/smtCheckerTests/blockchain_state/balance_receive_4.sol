contract C {
	uint c;
	function f() public payable {
		require(msg.value > 10);
		++c;
	}
	function inv() public view {
		assert(address(this).balance >= c * 11); // should hold
		assert(address(this).balance >= c * 12); // should fail
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTIgnoreOS: macos
// ----
// Warning 4984: (82-85): CHC: Overflow (resulting value larger than 2**256 - 1) might happen here.
// Warning 4984: (154-160): CHC: Overflow (resulting value larger than 2**256 - 1) might happen here.
// Warning 4984: (212-218): CHC: Overflow (resulting value larger than 2**256 - 1) might happen here.
// Warning 6328: (180-219): CHC: Assertion violation happens here.\nCounterexample:\nc = 1\n\nTransaction trace:\nC.constructor()\nState: c = 0\nC.f(){ msg.value: 11 }\nState: c = 1\nC.inv()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 2661: (82-85): BMC: Overflow (resulting value larger than 2**256 - 1) happens here.
// Warning 2661: (154-160): BMC: Overflow (resulting value larger than 2**256 - 1) happens here.
// Warning 2661: (212-218): BMC: Overflow (resulting value larger than 2**256 - 1) happens here.
