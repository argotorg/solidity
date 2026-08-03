contract C {
    function g() external pure {
    }

    function f() public pure {
        assert(msg.sig == this.g.selector);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (92-126): CHC: Assertion violation happens here.\nCounterexample:\n\n\nTransaction trace:\nC.constructor()\nC.f(){ msg.sig: 0x26121ff0 }
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
