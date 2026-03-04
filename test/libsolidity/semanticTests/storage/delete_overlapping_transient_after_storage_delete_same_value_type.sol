contract C {
    uint256 transient varTransient;
    uint256 public varStorage = 0xeeeeeeeeee;

    function setAndClear() external {
        varTransient = 0xffffffff;
        delete varStorage;
        delete varTransient;
        assert(varTransient == 0);
    }
}

// ====
// EVMVersion: >=cancun
// ----
// varStorage() -> 0xeeeeeeeeee
// setAndClear() ->
// varStorage() -> 0
