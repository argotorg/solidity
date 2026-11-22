contract C {
    mapping(uint => uint)[1] public immutable x;
}
// ----
// TypeError 6377: (17-60): Immutable variables cannot have a non-value type.
