struct S {
    mapping(uint => uint) m;
}
contract C {
    mapping(uint => uint)[2] immutable a;
    S[2] immutable b;
    S[] immutable c;
}
// ----
// TypeError 6377: (59-95): Immutable variables cannot have a non-value type.
// TypeError 8173: (59-95): Type mapping(uint256 => uint256)[2] is valid only in storage because it contains a mapping.
// TypeError 6377: (101-117): Immutable variables cannot have a non-value type.
// TypeError 8173: (101-117): Type struct S[2] is valid only in storage because it contains a mapping.
// TypeError 6377: (123-138): Immutable variables cannot have a non-value type.
// TypeError 8173: (123-138): Type struct S[] is valid only in storage because it contains a mapping.
