function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C {
    uint8[erc7201("85")] array;
    // The purpose of this test is to guarantee that the
    // erc7201 implementation does not subtract 1 only from the
    // last byte rather than the whole number during its intermediary operations.
    function builtinMatchesSolidityImplementation() public view returns (bool) {
        bytes32 h = keccak256(bytes("85"));

        // "85" is intentionally chosen because it produces
        // a keccak256 hash with the last byte zero
        assert(uint8(h[31]) == 0);

        return array.length == erc7201Mock("85");
    }
}
// ----
// builtinMatchesSolidityImplementation() -> true
