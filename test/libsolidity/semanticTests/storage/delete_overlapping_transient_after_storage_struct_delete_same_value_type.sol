contract C {
    struct S {
        uint256 a;
        address b;
    }

    S s = S(1, address(0x1234));
    uint256 transient t;

    function setAndDelete() external {
        t = 2;
        delete s;
        delete t;
        assert(t == 0);
    }

    function getS() external view returns (uint256, address) {
        return (s.a, s.b);
    }
}
// ====
// EVMVersion: >=cancun
// ----
// getS() -> 1, 0x1234
// setAndDelete() ->
// getS() -> 0, 0
