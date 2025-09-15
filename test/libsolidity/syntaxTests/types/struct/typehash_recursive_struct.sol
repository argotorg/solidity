contract C {
    struct S {
        S[] s;
    }

    bytes32 h = type(S).typehash;
}
// ----
