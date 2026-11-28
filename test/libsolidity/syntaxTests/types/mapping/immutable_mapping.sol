contract C {
    mapping(uint => uint) immutable a;
}
// ----
// TypeError 6377: (17-50): Immutable variables cannot have a non-value type.
