contract D {}

contract C {
    struct S { uint a; }

    function f() public pure {
        abi.encode(1)[0] = 0x01;
        type(D).creationCode[0] = 0x01;
        bytes("abc")[0] = "x";
        S(1).a = 2;
    }
}
// ----
// TypeError 5986: (93-109): Cannot modify part of a constant expression.
// TypeError 5986: (126-149): Cannot modify part of a constant expression.
// TypeError 5986: (166-181): Cannot modify part of a constant expression.
// TypeError 5986: (197-203): Cannot modify part of a constant expression.
