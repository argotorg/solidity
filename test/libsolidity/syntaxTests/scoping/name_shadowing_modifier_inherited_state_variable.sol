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
