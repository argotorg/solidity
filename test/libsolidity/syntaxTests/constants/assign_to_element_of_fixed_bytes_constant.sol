bytes32 constant B32 = "abc";

contract C {
    function f() public pure {
        B32[1] = "x";
        delete B32[2];
    }
}
// ----
// TypeError 4360: (83-89): Single bytes in fixed bytes arrays cannot be modified.
// TypeError 4360: (112-118): Single bytes in fixed bytes arrays cannot be modified.
