contract C {
    function f() public pure {
        // NOTE: memoryguard is a builtin but only in pure Yul, not inline assembly.
        // NOTE: memoryguard is not a reserved identifier.
        assembly { function memoryguard() {} }
        assembly { function f(memoryguard) {} }
        assembly { function f() -> memoryguard {} }
        assembly { let memoryguard }
    }
}
