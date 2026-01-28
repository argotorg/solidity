contract C
{
	function f(address payable a, address payable b) public {
		require(a.balance == 0);
		a.transfer(600);
		b.transfer(1000);
		// Fails since a == this is possible.
		assert(a.balance == 600);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 9207: (101-111): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 9207: (120-130): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 8656: (101-116): CHC: Insufficient funds happens here.\nCounterexample:\n\na = 0x0\nb = 0x0\n\nTransaction trace:\nC.constructor()\nC.f(0x0, 0x0)
// Warning 8656: (120-136): CHC: Insufficient funds happens here.\nCounterexample:\n\na = 0x0\nb = 0x0\n\nTransaction trace:\nC.constructor()\nC.f(0x0, 0x0)
// Warning 6328: (180-204): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x0476\nb = 0x0476\n\nTransaction trace:\nC.constructor()\nC.f(0x0476, 0x0476)
