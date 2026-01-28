contract C {
    uint k = 1;

    bytes32 constant a = keccak256(abi.encode(1, k));
    bytes32 constant b = keccak256(abi.encodePacked(uint(1), k));
    bytes32 constant c = keccak256(abi.encodeWithSelector(0x12345678, k, 2));
    bytes32 constant d = keccak256(abi.encodeWithSignature("f()", 1, k));
}
// ----
// TypeError 8349: (55-82): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (109-148): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (175-226): Initial value for constant variable has to be compile-time constant.
// TypeError 8349: (253-300): Initial value for constant variable has to be compile-time constant.
