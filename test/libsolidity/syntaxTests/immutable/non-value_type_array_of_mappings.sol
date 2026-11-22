contract C {
    mapping(uint => uint)[1] immutable x;
}
// ----
// TypeError 6377: (17-53): Immutable variables cannot have a non-value type.
