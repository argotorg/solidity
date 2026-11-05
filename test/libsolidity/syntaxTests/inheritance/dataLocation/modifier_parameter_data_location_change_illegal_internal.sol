abstract contract A {
    modifier m(uint256[1] memory a);
    function test(uint256[1] memory a) m(a) external {
    }
}

contract B is A {
    modifier m(uint256[1] calldata a) {
        _;
    }
}
// ----
// SyntaxError 8063: (26-58): Modifiers without implementation are not allowed.
// TypeError 5827: (145-197): Cannot override modifiers.
