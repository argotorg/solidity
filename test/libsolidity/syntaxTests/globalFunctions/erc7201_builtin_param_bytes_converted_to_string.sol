bytes constant bytesParam = "abcdef";
contract C {
    function f() public pure returns (uint256) {
        uint256 x = erc7201(string(bytesParam));
        return x;
    }
}
// ----
