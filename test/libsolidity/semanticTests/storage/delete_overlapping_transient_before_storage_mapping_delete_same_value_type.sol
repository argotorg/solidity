contract C {
    mapping(uint256 => uint256) m;
    uint256 transient t;

    function setAndClear() external {
        m[0] = 1;
        t = 2;
        delete t;
        assert(t == 0);
        delete m[0];
    }

    function getM() external view returns (uint256) {
        return m[0];
    }
}

// ====
// EVMVersion: >=cancun
// ----
// setAndClear() ->
// getM() -> 0
