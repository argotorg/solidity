library L {
	function l(address payable a) public {
		a.transfer(1);
	}
}

contract C {
	using L for address payable;
	uint x;
	function f(address payable a) public payable {
		require(msg.value > 1);
		uint b1 = address(this).balance;
		a.l();
		uint b2 = address(this).balance;
		assert(b1 == b2); // should fail
		assert(x == 0); // should fail because of `delegatecall`
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 9207: (54-64): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 4588: (238-243): Assertion checker does not yet implement this type of function call.
// Warning 8656: (54-67): CHC: Insufficient funds happens here.\nCounterexample:\n\na = 0x0\n\nTransaction trace:\nL.constructor()\nL.l(0x0)
// Warning 6328: (282-298): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\na = 0x0\nb1 = 15923\nb2 = 15924\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x0){ msg.value: 15923 }
// Warning 6328: (317-331): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\na = 0x0\nb1 = 15923\nb2 = 15924\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x0){ msg.value: 15923 }
