contract C {
    function f(uint x) public pure {
        if (x > 10) {
            assert(x > 9);
        }
        else if (x > 2)
        {
            assert(x <= 10 && x > 2);
        }
        else
        {
           assert(0 <= x && x <= 2);
        }
    }
}
// ====
// SMTEngine: all
// ----
// Info 1391: CHC: 3 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
