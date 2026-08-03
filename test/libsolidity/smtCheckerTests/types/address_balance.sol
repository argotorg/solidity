contract C
{
	function f(address a, address b) public view {
		uint x = b.balance + 1000 ether;
		assert(a.balance > b.balance);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 2072: (63-69): Unused local variable.
// Warning 4984: (72-94): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\n\na = 0x0\nb = 0x0\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(0x0, 0x0)
// Warning 6328: (98-127): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x0\nb = 0x0\nx = 1000000000000000000038\n\nTransaction trace:\nC.constructor()\nC.f(0x0, 0x0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
