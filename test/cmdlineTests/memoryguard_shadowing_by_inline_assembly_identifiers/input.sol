// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.0;

contract C {
    function f() public pure {
        // NOTE: memoryguard is a builtin but only in pure Yul, not inline assembly.
        // NOTE: memoryguard is not a reserved identifier.
        // The expectation of this test is to not see the shadowed memoryguard within the generated Yul code but rather
        // a mangled version of it
        assembly { function memoryguard() {} }
        assembly { function f(memoryguard) {} }
        assembly { function f() -> memoryguard {} }
        assembly { let memoryguard }
    }
}
