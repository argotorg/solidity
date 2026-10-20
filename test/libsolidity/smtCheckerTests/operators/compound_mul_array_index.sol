contract C
{
	uint[] array;
	function q() public { array.push(); }
	function f(uint x, uint p) public {
		require(p < array.length);
		require(x < 10);
		array[p] = 10;
		array[p] *= array[p] + x;
		assert(array[p] <= 190);
		assert(array[p] < 50);
	}
}
// ====
// SMTEngine: chc
// SMTIgnoreOS: macos
// ----
// Warning 6328: (226-247): CHC: Assertion violation happens here.\nCounterexample:\narray = [100]\nx = 0\np = 0\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.q()\nState: array = [0]\nC.f(0, 0)
// Info 1391: CHC: 8 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
