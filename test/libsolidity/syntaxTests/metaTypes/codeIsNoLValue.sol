contract Test {
    function f() public pure {
        type(C).creationCode = new bytes(6);
        type(C).runtimeCode = new bytes(6);
    }
}
contract C {}
// ====
// bytecodeFormat: legacy
// ----
// TypeError 4247: (55-75): Expression has to be an lvalue.
// TypeError 4247: (100-119): Expression has to be an lvalue.
