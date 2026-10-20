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
