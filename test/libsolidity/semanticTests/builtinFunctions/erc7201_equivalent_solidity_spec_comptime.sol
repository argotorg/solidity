function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C {
    uint8[erc7201("example.main")] array;

    function builtinMatchesSolidityImplementation() public view returns (bool) {
        return array.length == erc7201Mock("example.main");
    }
}
// ----
// builtinMatchesSolidityImplementation() -> true
