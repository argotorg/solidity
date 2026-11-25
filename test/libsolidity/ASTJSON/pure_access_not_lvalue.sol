contract C {
    struct S { uint a; }
    bytes constant B = "abc";
    function f(bytes memory m) public pure returns (bytes1, uint, uint, bytes1) {
        return (B[0], [1, 2][0], S(1).a, m[0]);
    }
}

// ----
