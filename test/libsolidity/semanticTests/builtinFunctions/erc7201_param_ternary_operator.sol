function erc7201Mock(string memory id) pure returns (uint256) {
    return uint256(
        keccak256(bytes.concat(bytes32(uint256(keccak256(bytes(id))) - 1))) &
        ~bytes32(uint256(0xff))
    );
}

contract C {
    function simple() public pure returns (bool) {
        return erc7201(true ? "x" : "y") == erc7201Mock("x");
    }
    function compounded(bool c1, bool c2) public pure returns (bool) {
        return erc7201(c1 ? "a" : (c2 ? "x" : "c")) == erc7201Mock("x");
    }
}
// ----
// simple() -> true
// compounded(bool,bool): false, true -> true
