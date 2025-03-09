contract C layout at 42 {
    uint public x;
    function f() public returns (uint r) {
        x = 16;
        assembly {
            r := sload(42)
        }
    }
}
// ----
// f() -> 16
// x() -> 16
