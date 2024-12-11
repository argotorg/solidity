contract C {
    function g() public returns (uint a, function() external h, uint b) {
        a = 1;
        h = this.fun;
        b = 9;
    }
    function f() public returns (uint, bool, uint) {
        // Note that the function type uses two stack slots.
        try this.g() returns (uint a, function() external h, uint b) {
            return (a, h == this.fun, b);
        } catch {
        }
    }
    function fun() public pure {}
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f() -> 1, true, 9
