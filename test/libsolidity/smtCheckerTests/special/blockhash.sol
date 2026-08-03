contract C
{
	function f(uint x) public payable {
		assert(blockhash(x) > 0);
		assert(blockhash(2) > 0);
		uint y = x;
		assert(blockhash(x) == blockhash(y));
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (52-76): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f(0){ msg.value: 19 }
// Warning 6328: (80-104): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f(0){ msg.value: 19 }
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
