library L {
	function l(address payable a) internal {
		require(a != address(this));
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
		assert(b1 == b2 + 1); // should hold
		assert(x == 0); // should hold
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 9207: (87-97): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 6328: (315-331): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\na = 0x7e1e\nb1 = 38\nb2 = 37\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x7e1e){ msg.value: 17 }\n    L.l(0x7e1e) -- internal call
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
