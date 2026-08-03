contract C {
    function f(uint a) public pure { assert(a == 2); }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: yes
// ----
// Warning 6328: (50-64): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
