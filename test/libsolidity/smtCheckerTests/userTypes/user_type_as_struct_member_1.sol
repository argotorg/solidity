contract C {
    type T is address;

    struct S {
        T a;
        uint x;
    }

    mapping (T => S) m;

    constructor() {
        m[T.wrap(address(0))] = S(T.wrap(address(0)), 0);
    }

    function set(address _a) external {
        m[T.wrap(_a)] = S(T.wrap(_a), 0);
    }

    function inv(T t) external view {
        assert( // should hold
            T.unwrap(m[t].a) == T.unwrap(t) ||
            T.unwrap(m[t].a) == address(0)
        );
    }
}
// ----
// Info 1391: CHC: 1 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
