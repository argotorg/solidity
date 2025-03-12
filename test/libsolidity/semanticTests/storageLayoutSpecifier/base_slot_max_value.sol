contract C layout at 2**256 - 1 {
    function f(uint a) public pure returns (uint) {
        return a * 2;
    }
}
// ----
// f(uint256): 4 -> 8
