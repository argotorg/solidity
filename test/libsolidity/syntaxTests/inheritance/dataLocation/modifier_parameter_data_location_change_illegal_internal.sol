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
// ParserError 8063: (57-58): Modifiers without implementation are not allowed.
