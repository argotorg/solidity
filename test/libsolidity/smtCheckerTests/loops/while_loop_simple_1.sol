// Check that variables are cleared
contract C {
    function f(uint x) public pure {
        x = 2;
        while (x > 1) {
            x = 1;
        }
        assert(x == 2);
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// SMTSolvers: z3
// ----
// Warning 6328: (162-176): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 1\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
