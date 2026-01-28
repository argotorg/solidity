// NOTE: memoryguard is a builtin but only in pure Yul, not inline assembly.
// NOTE: memoryguard is not a reserved identifier.

contract C {
    constructor() {
        // The expectation of this test is to see a 'true' outcome, indicating the memoryguard builtin being used
        // due to explicitly marking the inline assembly as memory-safe

        assembly ("memory-safe") { mstore(42, 42) function memoryguard() {} }
        assembly ("memory-safe") { mstore(42, 42) function f(memoryguard) {} }
        assembly ("memory-safe") { mstore(42, 42) function f() -> memoryguard {} }
        assembly ("memory-safe") { mstore(42, 42) let memoryguard }
    }

    function f() public pure {
        // The expectation of this test is to see a 'false' outcome, indicating the memoryguard builtin not being used

        assembly { mstore(42, 42) function memoryguard() {} }
        assembly { mstore(42, 42) function f(memoryguard) {} }
        assembly { mstore(42, 42) function f() -> memoryguard {} }
        assembly { mstore(42, 42) let memoryguard }
    }
}
// ----
// :C(creation) true
// :C(runtime) false
