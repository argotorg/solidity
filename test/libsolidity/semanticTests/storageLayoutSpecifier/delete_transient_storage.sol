contract C layout at 42 {
    uint transient x;
    address transient a;

    function f() public {
        g();
        delete x;
        delete a;
        assert(x == 0);
        assert(a == address(0));
    }
    function g() public {
        x = 99;
        a = address(0x1234);
    }
}
// ====
// EVMVersion: >=cancun
// ----
// f() ->