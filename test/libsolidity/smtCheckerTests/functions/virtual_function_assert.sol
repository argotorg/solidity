contract A {
    int x = 0;

    function f() virtual internal view {
        assert(x == 0);
    }

    function proxy() public view {
        f();
    }
}

contract C is A {

    function f() internal view override {
        assert(x == 1);
    }
}
// ====
// SMTEngine: all
// ----
// Warning 6328: (227-241): CHC: Assertion violation happens here.\nCounterexample:\nx = 0\n\nTransaction trace:\nC.constructor()\nState: x = 0\nA.proxy()\n    C.f() -- internal call
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
