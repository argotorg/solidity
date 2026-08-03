contract C {
    function f() public pure {
        uint x = 2;
        if (--x < 3) {}

        assert(x == 1); // should hold
        assert(x != 1); // should fail
    }
}
// ====
// SMTEngine: bmc
// ----
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Warning 6838: (76-83): BMC: Condition is always true.
// Warning 4661: (136-150): BMC: Assertion violation happens here.
// Info 6002: BMC: 2 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
