contract C
{
	uint[] array;
	function p() public { array.push(); }
	function f(uint x) public {
		require(x < array.length);
		array[x] = 5;
		uint a = --array[x];
		assert(array[x] == 4);
		assert(a == 4);
		uint b = array[x]--;
		assert(array[x] == 3);
		// Should fail.
		assert(b > 4);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (275-288): CHC: Assertion violation happens here.\nCounterexample:\narray = [3]\nx = 0\na = 4\nb = 4\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.p()\nState: array = [0]\nC.f(0)
// Info 1391: CHC: 10 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
