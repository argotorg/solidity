function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C {
    function builtinMatchesSolidityImplementation() public pure returns (bool) {
        return erc7201(unicode"Hello 😃") == erc7201Mock(unicode"Hello 😃");
    }
}
// ----
// builtinMatchesSolidityImplementation() -> true
