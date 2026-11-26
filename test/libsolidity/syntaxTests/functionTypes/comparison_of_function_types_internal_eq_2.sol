contract C {
    function f() internal {}
    function g() internal {}

    function test() public pure returns (bool) {
        function () internal ptr = C.f;
        return ptr == C.g;
    }
}
// ----
// TypeError 7641: (176-186): Comparison of internal function pointers is not allowed.
