uint256 constant ONE = 1;
int8 constant I8_NEGATIVE_63 = -63;
int8 constant I8_POSITIVE_127 = 127;
int16 constant I16_POSITIVE_127 = 127;

contract C {
    // right side cannot be signed
    int256 constant LITERAL_WRAP = -2**255 << ONE; // = 0
    uint[LITERAL_WRAP + 1] a;
    int8 constant CONST_NO_WRAP = I8_NEGATIVE_63 << 1;
    uint[CONST_NO_WRAP * -1] b;
    int8 constant CONST_WRAP = I8_POSITIVE_127 << 1; // = -2 (1111 1110)
    uint[CONST_WRAP * -1] c;
    int16 constant CONST_SIGN_CHANGED = I16_POSITIVE_127 << 9; // = -512 (1111 1110 0000 0000)
    uint[CONST_SIGN_CHANGED * -1] d;

    function testLiteralWrapEquivalence() public view returns (bool) {
        int256 runTimeResult = -2**255 << ONE;

        return
            LITERAL_WRAP == runTimeResult &&
            a.length == 1;
    }

    function testConstNoWrapEquivalence() public view returns (bool) {
        int8 runTimeResult = I8_NEGATIVE_63 << 1;

        return
            CONST_NO_WRAP == runTimeResult &&
            b.length == 126;
    }

    function testConstWrapEquivalence() public view returns (bool) {
        int8 runTimeResult = I8_POSITIVE_127 << 1;

        return
            CONST_WRAP == runTimeResult &&
            c.length == 2;
    }

    function testConstSignChanged() public view returns (bool) {
        int16 runTimeResult = I16_POSITIVE_127 << 9;

        return
            CONST_SIGN_CHANGED == runTimeResult &&
            d.length == 512;
    }
}
// ----
// testLiteralWrapEquivalence() -> true
// testConstNoWrapEquivalence() -> true
// testConstWrapEquivalence() -> true
// testConstSignChanged() -> true
