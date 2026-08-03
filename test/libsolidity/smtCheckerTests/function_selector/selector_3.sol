
contract C {
    int public x;
    int public y;

    function f() public pure {
        assert(this.x.selector != this.y.selector);
        assert(this.x.selector == this.y.selector);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (142-184): CHC: Assertion violation happens here.\nCounterexample:\nx = 0, y = 0\n\nTransaction trace:\nC.constructor()\nState: x = 0, y = 0\nC.f()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
