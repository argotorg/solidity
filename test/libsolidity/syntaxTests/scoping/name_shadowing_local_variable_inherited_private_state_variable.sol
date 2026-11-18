contract A {
    uint private x;
}

contract C is A {
    function f() public pure returns (uint) {
        uint x = 1;
        return x;
    }
}
