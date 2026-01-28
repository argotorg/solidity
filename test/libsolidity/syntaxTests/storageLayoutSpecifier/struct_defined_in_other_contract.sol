contract A {
    struct SA {
        uint x;
        uint y;
        bytes32 b;
    }
}

contract C is A layout at A.SA { }
// ----
// TypeError 1139: (115-119): The base slot of the storage layout must be a compile-time constant expression.
