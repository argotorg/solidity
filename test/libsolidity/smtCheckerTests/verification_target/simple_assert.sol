contract C {
    function f(uint a) public pure { assert(a == 2); }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (50-64): CHC: Assertion violation happens here.\nCounterexample:\n\na = 3\n\nTransaction trace:\nC.constructor()\nC.f(3)
