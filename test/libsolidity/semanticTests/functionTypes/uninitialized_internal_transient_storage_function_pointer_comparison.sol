contract C {
    uint32 public transient x;
    function() internal transient internalFunctionPointer;
    uint32 private transient y;

    function testComparison() public returns (bool) {
        x = 1;
        y = 2;
        function() internal uninitializedPointer;
        if (internalFunctionPointer == uninitializedPointer)
            return true;
        return false;
    }
    function testLocalAssignment() public returns (bool) {
        x = 1;
        y = 2;
        function() internal uninitializedPointer;
        function() internal localPointer = internalFunctionPointer;
        if (localPointer == uninitializedPointer)
            return true;
        return false;
    }
}
// ====
// EVMVersion: >=cancun
// ----
// testComparison() -> true
// testLocalAssignment() -> true
