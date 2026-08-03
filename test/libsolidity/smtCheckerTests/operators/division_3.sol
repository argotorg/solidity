contract C {
	function f(int x, int y) public pure returns (int) {
		require(y != 0);
		return x / y;
	}
}
// ====
// SMTEngine: all
// ----
// Warning 4984: (95-100): CHC: Overflow (resulting value larger than 2**255 - 1) happens here.\nCounterexample:\n\nx = (- 57896044618658097711785492504343953926634992332820282019728792003956564819968)\ny = (- 1)\n = 0\n\nTransaction trace:\nC.constructor()\nC.f((- 57896044618658097711785492504343953926634992332820282019728792003956564819968), (- 1))
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
