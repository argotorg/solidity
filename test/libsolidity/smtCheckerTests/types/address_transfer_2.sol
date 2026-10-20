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
// Warning 8656: (184-199): CHC: Insufficient funds happens here.\nCounterexample:\n\nx = 100\na = 0x0\nb = 0xffffffffffffffffffffffffffffffffffff886b\n\nTransaction trace:\nC.constructor()\nC.f(100, 0x0, 0xffffffffffffffffffffffffffffffffffff886b)
// Warning 8656: (203-218): CHC: Insufficient funds happens here.\nCounterexample:\n\nx = 100\na = 0x052c\nb = 0x052b\n\nTransaction trace:\nC.constructor()\nC.f(100, 0x052c, 0x052b)
// Warning 6328: (262-291): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 100\na = 0x16de\nb = 0x16dd\n\nTransaction trace:\nC.constructor()\nC.f(100, 0x16de, 0x16dd)
