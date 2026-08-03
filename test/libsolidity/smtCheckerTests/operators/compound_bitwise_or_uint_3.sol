contract C {
    struct S {
        uint x;
    }
    S s;
    function f(bool b) public {
        s.x |= b ? 1 : 2;
        assert(s.x > 0);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (125-140): CHC: Assertion violation might happen here.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
