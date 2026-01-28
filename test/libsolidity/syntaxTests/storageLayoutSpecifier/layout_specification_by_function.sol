function f() pure returns (uint256) {
    return 128;
}
contract C layout at f() { }
// ----
// TypeError 1139: (77-80): The base slot of the storage layout must be a compile-time constant expression.
