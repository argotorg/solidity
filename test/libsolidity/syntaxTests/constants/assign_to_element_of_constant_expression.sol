bytes constant B = "abc";
uint constant X = 123;

contract C {
    function f() public pure {
        (B)[1] = "x";
        (true ? B : B)[1] = "x";
        [B][0] = "x";
        [B][0][1] = "x";
        [X][0] = 456;
        [X][0] += 1;
        ++[X][0];
        delete [X][0];
    }
}
// ----
// TypeError 6520: (102-108): Cannot assign to a constant variable.
// TypeError 5986: (124-141): Cannot modify part of a constant expression.
// TypeError 5986: (157-163): Cannot modify part of a constant expression.
// TypeError 5986: (179-188): Cannot modify part of a constant expression.
// TypeError 5986: (204-210): Cannot modify part of a constant expression.
// TypeError 5986: (226-232): Cannot modify part of a constant expression.
// TypeError 5986: (249-255): Cannot modify part of a constant expression.
// TypeError 5986: (272-278): Cannot modify part of a constant expression.
