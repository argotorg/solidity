contract A {
    int x;
    int y;
}
contract C is A {
    modifier m(int x) {
        int y = x;
        require(y > 0);
        _;
    }
}
// ----
// Warning 2519: (87-92): This declaration shadows an existing declaration.
// Warning 2519: (70-75): This declaration shadows an existing declaration.
