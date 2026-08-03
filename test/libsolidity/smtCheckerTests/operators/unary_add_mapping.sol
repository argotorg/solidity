contract C
{
	mapping (uint => uint) map;
	function f(uint x) public {
		map[x] = 2;
		uint a = ++map[x];
		assert(map[x] == 3);
		assert(a == 3);
		uint b = map[x]++;
		assert(map[x] == 4);
		// Should fail.
		assert(b < 3);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (211-224): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\na = 3\nb = 3\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
