contract C {
    struct S {
        mapping(uint => uint)[1] maps;
    }

    function f() external {
        x.maps;
    }

    S immutable x;
}
// ----
// TypeError 6377: (129-142): Immutable variables cannot have a non-value type.
