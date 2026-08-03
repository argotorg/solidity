contract C {
    function f(uint x) public pure {
        uint a = 3;
        if (x > 10) {
            a = 5;
        }
        assert(a == 3);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (129-143): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 11\na = 5\n\nTransaction trace:\nC.constructor()\nC.f(11)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
