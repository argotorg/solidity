contract C  {
	function f(int x, int y) public pure returns (int) {
		require(x + y >= x);
		return x + y;
	}
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 3944: (78-83): CHC: Underflow (resulting value less than -2**255) happens here.\nCounterexample:\n\nx = (- 1)\ny = (- 57896044618658097711785492504343953926634992332820282019728792003956564819968)\n = 0\n\nTransaction trace:\nC.constructor()\nC.f((- 1), (- 57896044618658097711785492504343953926634992332820282019728792003956564819968))
// Warning 4984: (78-83): CHC: Overflow (resulting value larger than 2**255 - 1) happens here.\nCounterexample:\n\nx = 1\ny = 57896044618658097711785492504343953926634992332820282019728792003956564819967\n = 0\n\nTransaction trace:\nC.constructor()\nC.f(1, 57896044618658097711785492504343953926634992332820282019728792003956564819967)
// Info 1391: CHC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
