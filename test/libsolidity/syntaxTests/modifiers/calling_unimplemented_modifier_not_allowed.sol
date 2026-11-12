abstract contract C {
    modifier m;
    function f() public m() {}
}

contract D is C {
    function g() public m() {}
}
// ----
// ParserError 8063: (36-37): Modifiers without implementation are not allowed.
