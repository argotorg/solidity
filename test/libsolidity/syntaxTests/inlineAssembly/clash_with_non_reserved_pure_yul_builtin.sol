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
// ----
// Warning 5470: (207-232): "memoryguard" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
// Warning 5470: (265-276): "memoryguard" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
// Warning 5470: (318-329): "memoryguard" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
// Warning 5470: (358-369): "memoryguard" will be promoted to Yul reserved identifier in the future and will not be allowed anymore as an identifier.
