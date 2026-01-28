contract C
{
	function f(address payable a) public {
		uint x = 100;
		require(x == a.balance);
		a.transfer(600);
		// This fails since a == this is possible.
		assert(a.balance == 700);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 9207: (98-108): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 8656: (98-113): CHC: Insufficient funds happens here.\nCounterexample:\n\na = 0x51f0\nx = 100\n\nTransaction trace:\nC.constructor()\nC.f(0x51f0)
// Warning 6328: (162-186): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x0\nx = 100\n\nTransaction trace:\nC.constructor()\nC.f(0x0)
