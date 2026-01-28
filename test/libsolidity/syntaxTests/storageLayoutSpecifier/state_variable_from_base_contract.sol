contract A {
    uint public x = 10;
}

contract C is A layout at A.x {}
// ----
// TypeError 1139: (66-69): The base slot of the storage layout must be a compile-time constant expression.
