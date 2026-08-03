contract C {
    uint a;
    function f(uint x) public {
        this.g(x);
        assert(a == x);
        assert(a != 42);
    }

    function g(uint x) public {
        a = x;
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (108-123): CHC: Assertion violation happens here.\nCounterexample:\na = 42\nx = 42\n\nTransaction trace:\nC.constructor()\nState: a = 0\nC.f(42)\n    C.g(42) -- trusted external call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
