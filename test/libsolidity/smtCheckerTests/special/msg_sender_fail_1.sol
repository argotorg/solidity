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
// Warning 6328: (122-145): CHC: Assertion violation happens here.\nCounterexample:\n\nc = 0x0\na = 0xffffffffffffffffffffffffffffffffffffdd68\nb = 0xffffffffffffffffffffffffffffffffffffdd68\n\nTransaction trace:\nC.constructor()\nC.f(0x0){ msg.sender: 0xffffffffffffffffffffffffffffffffffffdd68 }
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
