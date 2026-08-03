// Check that condition is not assumed after the body anymore
contract C {
    function f(uint x) public pure {
        while (x == 2) {
        }
        assert(x == 2);
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// SMTSolvers: z3
// ----
// Warning 6328: (155-169): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
