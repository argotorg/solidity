contract C {
    type T is address;
    mapping (T => uint) s;

    constructor() {
        s[T.wrap(address(0))] = 42;
    }

    function f(address a) external view {
        require(a != address(0));
        assert(s[C.T.wrap(a)] == 0); // should hold
    }

    function g(T a) external view {
        require(C.T.unwrap(a) == address(0));
        assert(s[a] != 42); // should fail
    }
}
// ----
// Warning 6328: (352-370): CHC: Assertion violation happens here.\nCounterexample:\n\na = 0x0\n\nTransaction trace:\nC.constructor()\nC.g(0x0)
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
