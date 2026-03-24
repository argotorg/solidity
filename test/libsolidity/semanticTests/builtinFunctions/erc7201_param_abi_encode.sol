function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C {
    function builtinMatchesSolidityImplementation() public pure returns (bool) {
        return
            erc7201(string(abi.encode("example.main"))) ==
            erc7201Mock(string(abi.encode("example.main")));
    }
    function builtinOutput() public pure returns (uint) {
        return erc7201(string(abi.encode("example.main")));
    }
}
// ----
// builtinMatchesSolidityImplementation() -> true
// builtinOutput() -> -14651554186193368082021334953908208762193027200365752719897746810709432803072
