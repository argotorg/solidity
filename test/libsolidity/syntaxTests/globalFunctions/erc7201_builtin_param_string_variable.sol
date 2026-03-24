string constant fileLevelStr = "test.file";
contract C {
    string constant stateVarStr = "example.contract";
    function fileLevel() public pure returns (uint) {
        return erc7201(fileLevelStr);
    }
    function stateVar() public pure returns (uint) {
        return erc7201(stateVarStr);
    }
    function localVar() public pure returns (uint) {
        string memory localVarStr = "example.main";
        return erc7201(localVarStr);
    }
    function funcMemParam(string memory paramStr) public pure returns (uint) {
        return erc7201(paramStr);
    }
    function funcCallDataParam(string calldata paramStr) public pure returns (uint) {
        return erc7201(paramStr);
    }
}
// ----
