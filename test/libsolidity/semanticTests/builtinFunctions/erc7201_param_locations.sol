function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C {
    string storageVarStr = "example.contract";
    string constant constStorageVarStr = "example.contract";
    function storageVar() public view returns (bool) {
        return erc7201(storageVarStr) == erc7201Mock("example.contract");
    }
    function constStorageVar() public pure returns (bool) {
        return erc7201(constStorageVarStr) == erc7201Mock("example.contract");
    }
    function memoryVar() public pure returns (bool) {
        string memory memoryVarStr = "example.main";
        return erc7201(memoryVarStr) == erc7201Mock("example.main");
    }
    function calldataParam(string calldata calldataVarStr) public pure returns (bool) {
        return erc7201(calldataVarStr) == erc7201Mock("example.main");
    }
    function calldataSlice(bytes calldata namespaceID) public pure returns (bool) {
        return erc7201(string(namespaceID[2:5])) == erc7201Mock("amp");
    }
    function literalParam() public pure returns (bool) {
        return erc7201("example.main") == erc7201Mock("example.main");
    }
}
// ----
// storageVar() -> true
// constStorageVar() -> true
// memoryVar() -> true
// calldataParam(string): 0x20, 12, "example.main" -> true
// calldataSlice(bytes): 0x20, 12, "example.main" -> true
// literalParam() -> true
