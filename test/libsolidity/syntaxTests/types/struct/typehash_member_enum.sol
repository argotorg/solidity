contract C {
    enum E {
        VALUE
    }

    struct S {
        E e;
    }

    bytes32 h = type(S).typehash;
}

// ----
