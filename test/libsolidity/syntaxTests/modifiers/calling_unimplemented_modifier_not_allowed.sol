abstract contract C {
    modifier m;
    function f() public m() {}
}

contract D is C {
    function g() public m() {}
}
// ----
// SyntaxError 8063: (26-37): Modifiers without implementation are not allowed.
