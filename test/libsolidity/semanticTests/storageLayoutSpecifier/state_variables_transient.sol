contract C layout at 42 {
    int x;
    bool transient lock;

    function test() public returns(int) {
        x = -1;
        lock = true;
        f();
        return x;
    }
    function f() private {
        lock = false;
        setX();
    }
    function setX() private {
        require(!lock);
        x = 2;
    }
}
// ====
// EVMVersion: >=cancun
// ----
// test() -> 2