contract C layout at 42 {
    uint constant x = 10;
    uint immutable y = 100;

    function f() public view returns (uint) {
        require(x > 9);
        return x + 1;
    }
    function g() public view returns (uint) {
        require(y > 99);
        return y * 2;
    }
}
// ----
// f() -> 11
// g() -> 200
