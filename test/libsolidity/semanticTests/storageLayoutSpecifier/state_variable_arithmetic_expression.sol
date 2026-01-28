contract C layout at 7 {
    uint public x;
    uint public y;
    uint public z;

    function f(uint a) public returns (uint) {
        x = x + a;
        y = y + x;
        z = y - 2;

        return z;
    }
}
// ----
// f(uint256): 2 -> 0
// f(uint256): 3 -> 5
// f(uint256): 5 -> 15
// x() -> 10
// y() -> 17
// z() -> 15
