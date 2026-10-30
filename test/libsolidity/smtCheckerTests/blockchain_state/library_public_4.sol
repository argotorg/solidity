library L {
	function l(address payable a) public returns (address) {
		return msg.sender;
	}
}

contract C {
	using L for address payable;
	uint x;
	function f(address payable a) public payable {
		require(msg.value > 1);
		uint b1 = address(this).balance;
		address v = a.l();
		uint b2 = address(this).balance;
		assert(b1 == b2); // should fail because the called library can transfer with `this`s balance
		assert(x == 0); // should fail because of `delegatecall`
		assert(v == msg.sender); // should hold but we don't support `delegatecall` properly yet.
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 5667: (24-41): Unused function parameter. Remove or comment out the variable name to silence this warning.
// Warning 2018: (13-93): Function state mutability can be restricted to view
// Warning 4588: (272-277): Assertion checker does not yet implement this type of function call.
// Warning 6328: (316-332): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\na = 0x0\nb1 = 8947\nv = 0x0\nb2 = 8948\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x0){ msg.sender: 0x7e1d, msg.value: 8947 }
// Warning 6328: (412-426): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\na = 0x0\nb1 = 26287\nv = 0x0\nb2 = 26288\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x0){ msg.sender: 0x28d2, msg.value: 26287 }
// Warning 6328: (471-494): CHC: Assertion violation happens here.\nCounterexample:\nx = 1\na = 0x0\nb1 = 11798\nv = 0x2298\nb2 = 11797\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x0){ msg.sender: 0x2297, msg.value: 8947 }
