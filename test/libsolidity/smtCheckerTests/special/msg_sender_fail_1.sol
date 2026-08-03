contract C
{
	function f(address c) public view {
		address a = msg.sender;
		address b = msg.sender;
		assert(a == b);
		assert(c == msg.sender);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (122-145): CHC: Assertion violation happens here.\nCounterexample:\n\nc = 0x2298\na = 0x2297\nb = 0x2297\n\nTransaction trace:\nC.constructor()\nC.f(0x2298){ msg.sender: 0x2297 }
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
