// Variable is not merged, if it is only read.
contract C {
    function f(uint x) public pure {
        uint a = 3;
        if (x > 10) {
            assert(a == 3);
        } else {
            assert(a == 3);
        }
        assert(a == 3);
    }
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
