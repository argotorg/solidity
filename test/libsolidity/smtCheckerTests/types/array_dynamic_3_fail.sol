contract C
{
	uint[][][] array;
	function p() public {
		array.push().push().push();
	}
	function f(uint x, uint y, uint z, uint t, uint w, uint v) public {
		require(x < array.length);
		require(y < array[x].length);
		require(z < array[x][y].length);
		array[x][y][z] = 200;
		require(x == t && y == w && z == v);
		assert(array[t][w][v] > 300);
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (318-346): CHC: Assertion violation happens here.\nCounterexample:\narray = [[[200]]]\nx = 0\ny = 0\nz = 0\nt = 0\nw = 0\nv = 0\n\nTransaction trace:\nC.constructor()\nState: array = []\nC.p()\nState: array = [[[0]]]\nC.f(0, 0, 0, 0, 0, 0)
// Info 1391: CHC: 9 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
