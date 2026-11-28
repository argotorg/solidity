struct S {
    mapping(uint => uint) m;
}
struct T {
    S[2] s;
}
contract C {
    function f(bytes memory data) public pure {
        abi.decode(data, (S));
        abi.decode(data, (T));
        abi.decode(data, (S[]));
        abi.decode(data, (uint, S[2], uint));
    }
}
// ----
// TypeError 9611: (154-155): Decoding type struct S memory not supported.
// TypeError 5130: (154-155): Type struct S is valid only in storage because it contains a (nested) mapping.
// TypeError 9611: (185-186): Decoding type struct T memory not supported.
// TypeError 5130: (185-186): Type struct T is valid only in storage because it contains a (nested) mapping.
// TypeError 9611: (216-219): Decoding type struct S[] memory not supported.
// TypeError 5130: (216-219): Type struct S[] is valid only in storage because it contains a (nested) mapping.
// TypeError 9611: (255-259): Decoding type struct S[2] memory not supported.
// TypeError 5130: (255-259): Type struct S[2] is valid only in storage because it contains a (nested) mapping.
