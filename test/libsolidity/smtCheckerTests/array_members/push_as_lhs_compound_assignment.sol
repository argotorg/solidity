contract C {

	int[] u;

	function t() public {
		require(u.length == 0);
		u.push() -= 1;
		assert(u[0] < 0); // should hold
		assert(u[0] >= 0); // should fail
	}
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (128-145): CHC: Assertion violation happens here.\nCounterexample:\nu = [(- 1)]\n\nTransaction trace:\nC.constructor()\nState: u = []\nC.t()
// Info 1391: CHC: 5 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
