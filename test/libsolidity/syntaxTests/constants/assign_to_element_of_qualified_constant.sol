library L {
    bytes constant B = "abc";
}

contract C {
    bytes constant B = "abc";

    function f() public pure {
        L.B[0] = "x";
        C.B[0] = "x";
    }
}
// ----
// TypeError 5986: (128-134): Cannot modify part of a temporary value, the change would be lost.
// TypeError 5986: (150-156): Cannot modify part of a temporary value, the change would be lost.
