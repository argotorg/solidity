contract C {
    bool[3] flags = [true, true, true];
    uint256 transient temp;

    function setAndClear() external {
        temp = 0xffffffff;
        delete temp;
        assert(temp == 0);
        delete flags;
    }

    function getFlags() external returns(bool[3] memory)
    {
        return flags;
    }
}

// ====
// EVMVersion: >=cancun
// ----
// getFlags() -> true, true, true
// setAndClear() ->
// getFlags() -> false, false, false
