contract C {
	function f(bytes calldata x, uint y) external pure {
		require(x.length > 10);
		x[8][0];
		x[8][5*y];
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 4984: (111-114): CHC: Overflow (resulting value larger than 2**256 - 1) happens here.\nCounterexample:\n\nx = [0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x29, 0x0a, 0x0a, 0x97, 0x0a, 0x0a]\ny = 23158417847463239084714197001737581570653996933128112807891516801582625927988\n\nTransaction trace:\nC.constructor()\nC.f([0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x29, 0x0a, 0x0a, 0x97, 0x0a, 0x0a], 23158417847463239084714197001737581570653996933128112807891516801582625927988)
// Warning 6368: (106-115): CHC: Out of bounds access happens here.\nCounterexample:\n\nx = [0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x33, 0x0c, 0x97, 0x0c, 0x0c]\ny = 1\n\nTransaction trace:\nC.constructor()\nC.f([0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x33, 0x0c, 0x97, 0x0c, 0x0c], 1)
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
