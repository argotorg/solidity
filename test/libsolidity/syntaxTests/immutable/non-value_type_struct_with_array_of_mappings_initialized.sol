contract C {
    struct S {
        mapping(uint => uint)[1] maps;
    }

    S immutable x = x.maps;
}
// ----
// TypeError 6377: (78-100): Immutable variables cannot have a non-value type.
