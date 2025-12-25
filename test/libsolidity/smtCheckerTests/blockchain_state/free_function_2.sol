function l(address payable a) {
	a.transfer(1);
}

contract C {
	uint x;
	function f(address payable a) public payable {
		require(msg.value > 1);
		uint b1 = address(this).balance;
		require(a != address(this));
		l(a);
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
// Warning 9207: (33-43): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 6328: (258-274): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\na = 0x7e1e\nb1 = 38\nb2 = 37\n\nTransaction trace:\nC.constructor()\nState: x = 0\nC.f(0x7e1e){ msg.value: 17 }\n    l(0x7e1e) -- internal call
// Info 1391: CHC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
