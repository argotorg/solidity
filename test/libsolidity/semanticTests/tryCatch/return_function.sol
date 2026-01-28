contract C {
    function g() public returns (uint a, function() external h, uint b) {
        a = 1;
        h = C(address(0x1234)).fun;
        b = 9;
    }
    function f() public returns (uint, function() external, uint) {
        // Note that the function type uses two stack slots.
        try this.g() returns (uint a, function() external h, uint b) {
            return (a, h, b);
        } catch {
        }
    }
    function fun() public pure {}
}
// ----
// f() -> 0x1, 0x1234946644cd0000000000000000, 9
