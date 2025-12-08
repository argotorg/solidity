abstract contract A {
    modifier m(uint256[1] memory a) virtual;
    function test(uint256[1] memory a) m(a) external {
    }
}

contract B is A {
    modifier m(uint256[1] calldata a) override {
        _;
    }
}
// ----
// Warning 8429: (26-66): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 1078: (153-214): Override changes modifier signature.
