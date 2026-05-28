contract C {
    int256 constant CONST = 42;
    function test() public pure {
        assert(~-CONST == ~-42);
    }
}
// ====
// SMTEngine: chc
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
