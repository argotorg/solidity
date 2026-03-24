function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C {
    // value from EIP-7201 (https://eips.ethereum.org/EIPS/eip-7201)
    uint expectedSlot = 0x183a6125c38840424c4a85fa12bab2ab606c4b6d0e7cc73c0c06ba5300eab500;
    string namespace = "example.main";

    function builtinMatchesSolidityImplementation() public view returns (bool) {
        assert(expectedSlot == erc7201Mock(namespace));

        return
            erc7201(namespace) == erc7201Mock("example.main") &&
            erc7201("example.main") == erc7201Mock("example.main");
    }
    function builtinOutput() public view returns (uint) {
        return erc7201(namespace);
    }
}
// ----
// builtinMatchesSolidityImplementation() -> true
// builtinOutput() -> 0x183a6125c38840424c4a85fa12bab2ab606c4b6d0e7cc73c0c06ba5300eab500
