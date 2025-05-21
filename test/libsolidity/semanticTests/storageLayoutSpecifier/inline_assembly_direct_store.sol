contract C layout at 42 {
    uint public x;
    function f() public returns (uint) {
        assembly {
            sstore(42, 16)
        }
        return x;
    }
}
// ----
// f() -> 16
// x() -> 16
