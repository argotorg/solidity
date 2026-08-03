contract C {
    uint x = ((((C)))).x = ((C)).x = 2;

    function f() external view {
        assert(x == 2); // should hold
    }

    function g() external view {
        assert(x != 2); // should fail
    }
}
// ====
// SMTEngine: all
// SMTIgnoreCex: no
// ----
// Warning 6328: (174-188): CHC: Assertion violation happens here.\nCounterexample:\nx = 2\n\nTransaction trace:\nC.constructor()\nState: x = 2\nC.g()
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
