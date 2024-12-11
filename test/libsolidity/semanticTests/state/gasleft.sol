contract C {
    function f() public returns (bool) {
        return gasleft() > 0;
    }
}
// ====
// bytecodeFormat: legacy
// ----
// f() -> true
// f() -> true
// f() -> true
