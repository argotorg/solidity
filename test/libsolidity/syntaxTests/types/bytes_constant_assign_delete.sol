bytes constant B = "abc";

contract C {
    function f() public pure returns (bytes memory) {
        B[1] = "x";
        delete B[2];
        return B;
    }
}
// ----
// TypeError 6520: (102-106): Cannot assign to a constant variable.
// TypeError 6520: (129-133): Cannot assign to a constant variable.
