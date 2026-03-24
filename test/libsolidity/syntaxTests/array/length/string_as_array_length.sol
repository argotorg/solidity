contract C {
    string constant length = "length";
    uint["length"] literalString;
    uint[length] variableString;
}
// ----
// TypeError 5462: (61-69): Invalid array length, expected integer literal or constant expression.
// TypeError 5462: (95-101): Invalid array length, expected integer literal or constant expression.
