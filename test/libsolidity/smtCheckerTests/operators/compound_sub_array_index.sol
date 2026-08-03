contract C
{
	uint[] array;
	function q() public { array.push(); }
	function f(uint x, uint p) public {
		require(p < array.length);
		require(x < 100);
		array[p] = 200;
		array[p] -= array[p] - x;
		assert(array[p] >= 0);
		assert(array[p] < 90);
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (226-247): CHC: Assertion violation happens here.\nCounterexample:\narray = [90]\nx = 90\np = 0\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.q()\nState: array = [0]\nC.f(90, 0)
// Info 1391: CHC: 8 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
