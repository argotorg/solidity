contract C {
    function f() payable public {
        bytes32 h = keccak256(abi.encodePacked(keccak256, f, this.f{value: 2}, blockhash));
        h;
    }
}
// ----
// TypeError 2056: (94-103): This type cannot be encoded.
// TypeError 2056: (105-106): This type cannot be encoded.
// TypeError 2056: (108-124): This type cannot be encoded.
// TypeError 2056: (126-135): This type cannot be encoded.
