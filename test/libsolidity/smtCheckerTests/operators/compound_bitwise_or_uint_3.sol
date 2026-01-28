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
// Info 6002: BMC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
