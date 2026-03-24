function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C layout at erc7201("example.main") {
    uint x;
    function builtinMatchesSolidityImplementation() public pure returns (bool) {
        uint firstSlot;
        assembly {
            firstSlot := x.slot
        }
        return firstSlot == erc7201Mock("example.main");
    }
}
// ----
// builtinMatchesSolidityImplementation() -> true
