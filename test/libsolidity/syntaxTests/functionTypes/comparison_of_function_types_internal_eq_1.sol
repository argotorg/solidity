contract C {
    function f() public pure returns (bool ret) {
        return f == f;
    }
    function g() public pure returns (bool ret) {
        return f != f;
    }
}
// ----
// TypeError 7641: (78-84): Comparison of internal function pointers is not allowed.
// TypeError 7641: (157-163): Comparison of internal function pointers is not allowed.
