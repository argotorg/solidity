contract A {
    function f() external payable returns (uint) {}
}
contract C is A layout at this.f{value:123}() {}
// ----
// TypeError 1139: (93-112): The base slot of the storage layout must be a compile-time constant expression.
