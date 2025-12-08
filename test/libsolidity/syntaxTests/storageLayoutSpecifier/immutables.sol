function f() returns (uint) {
    return 2;
}

contract A {
    address immutable a = 0x0000000000000000000000000000000000000001;
    uint immutable x = 1; // considered pure by the compiler (initialized with a literal)
    uint immutable y = f(); // considered not pure by the compiler (initialized with a function)
}

contract B is A layout at A.a { }
contract C is A layout at A.x { }
contract D is A layout at A.y { }
// ----
// TypeError 1139: (346-349): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (380-383): The base slot of the storage layout must be a compile-time constant expression.
// TypeError 1139: (414-417): The base slot of the storage layout must be a compile-time constant expression.
