contract C {
    // tests that bitwise operators are parsed from z3 answer
    function test(uint x, uint y) public pure {
        x | y;
        x & y;
        x ^ y;
        assert(true);
    }
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
