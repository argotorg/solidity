// TODO: This test case should work the same way for EOF but EOF immutables support is not in its final state yet.
contract C {
    uint immutable x;
    constructor() {
        x = 0;
        while (true)
        {}
    }
    function f() external view returns(uint) { return x; }
}
// ====
// bytecodeFormat: legacy
// optimize-yul: true
// ----
// CodeGenerationError 1284: (115-283): Some immutables were read from but never assigned, possibly because of optimization.
