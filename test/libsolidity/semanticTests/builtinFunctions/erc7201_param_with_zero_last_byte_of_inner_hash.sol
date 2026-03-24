function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C {
    // The purpose of this test is to guarantee that the
    // erc7201 implementation does not subtract 1 only from the
    // last byte rather than the whole number during its intermediary operations.
    function builtinMatchesSolidityImplementation() public pure returns (bool) {
        string memory s = "85";
        bytes32 h = keccak256(bytes(s));

        // "85" is intentionally chosen because it produces
        // a keccak256 hash with the last byte zero
        assert(uint8(h[31]) == 0);

        return
            erc7201(s) == erc7201Mock(s) &&
            erc7201("85") == erc7201Mock("85");
    }
}
// ----
// builtinMatchesSolidityImplementation() -> true
