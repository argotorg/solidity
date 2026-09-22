bytes32 constant B32 = "abc";

contract C {
    function f() public returns (bytes32) {
        B32[1] = "x";
        delete B32[2];
        return B32;
    }
}
// ----
// TypeError 6520: (96-102): Cannot assign to a constant variable.
// TypeError 6520: (125-131): Cannot assign to a constant variable.
