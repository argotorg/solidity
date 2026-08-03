contract C {
    function f() public pure {
        uint x = 2;
        uint y = (--x < 3) ? --x : 0;

        assert(y == x); // should hold
        assert(x == 0); // should hold
        assert(x != 0); // should fail
    }
}
// ====
// SMTEngine: bmc
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (81-90): BMC: Condition is always true.
// Warning 4661: (189-203): BMC: Assertion violation happens here.
// Info 6002: BMC: 4 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
