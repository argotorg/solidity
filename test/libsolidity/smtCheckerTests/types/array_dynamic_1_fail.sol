contract C
{
	uint[] array;
	function p() public { array.push(); }
	function f(uint x, uint y) public {
		require(x < array.length);
		array[x] = 200;
		require(x == y);
		assert(array[y] > 300);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (172-194): CHC: Assertion violation happens here.\nCounterexample:\narray = [200]\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.p()\nState: array = [0]\nC.f(0, 0)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
