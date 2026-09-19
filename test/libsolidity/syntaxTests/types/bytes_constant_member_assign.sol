bytes constant B = "abc";

contract C {
    function f() public pure {
        B.length = 5;
    }
}
// ----
// TypeError 6520: (79-87): Cannot assign to a constant variable.

