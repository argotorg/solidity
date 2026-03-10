contract A {
    struct S {
        C.S[] s;
    }
}
contract C {
    struct S {
        A.S s;
    }

    bytes32 h = type(S).typehash;
}
// ----
