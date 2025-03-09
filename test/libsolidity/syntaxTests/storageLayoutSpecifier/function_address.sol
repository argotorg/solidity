contract A {
    function f() public pure {}
}

contract C is A layout at this.f.address {}
// ----
// TypeError 1139: (74-88): The base slot of the storage layout must be a compile-time constant expression.
