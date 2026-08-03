contract C {
    function f(bool x, bool y) public pure {
        assert(x == y);
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (66-80): CHC: Assertion violation happens here.\nCounterexample:\n\nx = false\ny = true\n\nTransaction trace:\nC.constructor()\nC.f(false, true)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
