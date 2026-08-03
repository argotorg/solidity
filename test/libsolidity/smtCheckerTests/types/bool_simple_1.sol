contract C {
    function f(bool x) public pure {
        assert(x);
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (58-67): CHC: Assertion violation happens here.\nCounterexample:\n\nx = false\n\nTransaction trace:\nC.constructor()\nC.f(false)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
