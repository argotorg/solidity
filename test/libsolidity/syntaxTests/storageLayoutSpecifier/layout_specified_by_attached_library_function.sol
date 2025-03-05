library L {
    function f(uint x) public pure returns (uint) {
        return x * 2;
    }
}


contract C layout at 2.f() {
    using L for *;
}
// ----
// TypeError 1139: (117-122): The base slot of the storage layout must be a compile-time constant expression.
