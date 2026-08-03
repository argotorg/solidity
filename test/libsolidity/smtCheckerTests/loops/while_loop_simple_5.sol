// Check that side-effects of condition are taken into account
contract C {
    function f(uint x, uint y) public pure {
        x = 7;
        while ((x = y) > 0) {
			--y;
        }
        assert(x == 7);
    }
}
// ====
// SMTEngine: all
// SMTSolvers: z3
// ----
// Warning 6328: (192-206): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\ny = 0\n\nTransaction trace:\nC.constructor()\nC.f(0, 0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
