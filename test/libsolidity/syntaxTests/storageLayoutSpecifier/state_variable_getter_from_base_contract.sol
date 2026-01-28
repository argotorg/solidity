contract A {
    uint public x = 10;
}

contract C is A layout at this.x() {}
// ----
// TypeError 1139: (66-74): The base slot of the storage layout must be a compile-time constant expression.
