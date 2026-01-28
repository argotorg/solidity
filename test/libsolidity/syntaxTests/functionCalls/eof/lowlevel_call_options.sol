contract C {
    function foo() internal {
        (bool success, ) = address(10).call{value: 7}("");
        success;
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
