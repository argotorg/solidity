contract C
{
	uint[][] array;
	function f(uint x, uint y, uint z, uint t) public view {
		require(array[x][y] == 200);
		require(x == z && y == t);
		assert(array[z][t] > 100);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6368: (98-106): CHC: Out of bounds access happens here.\nCounterexample:\narray = []\nx = 0\ny = 0\nz = 0\nt = 0\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.f(0, 0, 0, 0)
// Warning 6368: (98-109): CHC: Out of bounds access happens here.\nCounterexample:\narray = []\nx = 0\ny = 0\nz = 0\nt = 0\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.f(0, 0, 0, 0)
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
