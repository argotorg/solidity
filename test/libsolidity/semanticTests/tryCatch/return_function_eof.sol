contract C {
    function g() public returns (uint a, function() external h, uint b) {
        a = 1;
        h = this.fun;
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
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f() -> 0x1, 0x9af5ffe522062ee0c1ed0c96288c657f99645bb7946644cd0000000000000000, 9
