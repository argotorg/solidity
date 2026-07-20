contract C {
    uint constant CONST0 = erc7201();
    uint[CONST0] a;
    uint constant CONST2 = erc7201("12", "34");
    uint[CONST2] b;
    uint constant CONST3 = erc7201("A", "BC", "D");
    uint[CONST3] c;
}
// ----
// TypeError 8248: (40-49): erc7201 function expects 1 parameter, but 0 were given.
// TypeError 5462: (60-66): Invalid array length, expected integer literal or constant expression.
// TypeError 8248: (98-117): erc7201 function expects 1 parameter, but 2 were given.
// TypeError 5462: (128-134): Invalid array length, expected integer literal or constant expression.
// TypeError 8248: (166-189): erc7201 function expects 1 parameter, but 3 were given.
// TypeError 5462: (200-206): Invalid array length, expected integer literal or constant expression.
