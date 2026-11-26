contract C {
    struct S {
        mapping(uint => uint)[1] maps;
    }

    S public immutable x;
}
// ----
// TypeError 6377: (78-98): Immutable variables cannot have a non-value type.
