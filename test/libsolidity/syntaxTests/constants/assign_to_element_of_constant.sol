bytes constant B = "abc";

contract C {
    function f() public pure {
        B[1] = "x";
        delete B[2];
        B[0] |= "y";
    }
}
// ----
// TypeError 6520: (79-83): Cannot assign to a constant variable.
// TypeError 6520: (106-110): Cannot assign to a constant variable.
// TypeError 6520: (120-124): Cannot assign to a constant variable.
