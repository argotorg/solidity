pragma experimental SMTChecker;
contract C {
    function f(uint x) public pure {
        assert(x > 0);
    }
}
// ----
// Warning 5523: (0-31): The SMTChecker pragma has been deprecated and will be removed in the future. Please use the "model checker engine" compiler setting to activate the SMTChecker instead. If the pragma is enabled, all engines will be used.
// Warning 6328: (90-103): CHC: Assertion violation happens here.\nCounterexample:\n\nx = 0\n\nTransaction trace:\nC.constructor()\nC.f(0)
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
