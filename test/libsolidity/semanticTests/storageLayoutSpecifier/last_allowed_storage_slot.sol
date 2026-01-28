contract C layout at 2**256 - 2 {
    uint public x;
    function f(uint a) public returns (uint) {
        x = a * 2;
        return x;
    }
}
// ----
// f(uint256): 4 -> 8
// x() -> 8
