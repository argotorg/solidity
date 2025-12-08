contract C
{
	function f(uint x, address payable a, address payable b) public {
		require(a != b);
		require(x == 100);
		require(x == a.balance);
		require(a.balance == b.balance);
		a.transfer(600);
		b.transfer(100);
		// Fails since a == this is possible.
		assert(a.balance > b.balance);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 9207: (184-194): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 9207: (203-213): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 8656: (184-199): CHC: Insufficient funds happens here.\nCounterexample:\n\nx = 100\na = 0x6532\nb = 0xffffffffffffffffffffffffffffffffffffed9d\n\nTransaction trace:\nC.constructor()\nC.f(100, 0x6532, 0xffffffffffffffffffffffffffffffffffffed9d)
// Warning 8656: (203-218): CHC: Insufficient funds happens here.\nCounterexample:\n\nx = 100\na = 0x08c0\nb = 0x7992\n\nTransaction trace:\nC.constructor()\nC.f(100, 0x08c0, 0x7992)
// Warning 6328: (262-291): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 100\na = 0x08c1\nb = 0x08c0\n\nTransaction trace:\nC.constructor()\nC.f(100, 0x08c1, 0x08c0)
