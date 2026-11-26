contract C {
    mapping(uint => uint)[1][2] immutable x;
}
// ----
// TypeError 6377: (17-56): Immutable variables cannot have a non-value type.
