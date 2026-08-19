contract C {
    uint32 public x = 1;
    function() internal internalFunctionPointer;
    uint32 private y = 2;

    function testComparison() public view returns (bool) {
        function() internal uninitializedPointer;
        if (internalFunctionPointer == uninitializedPointer)
            return true;
        return false;
    }
    function testLocalAssignment() public view returns (bool) {
        function() internal uninitializedPointer;
        function() internal localPointer = internalFunctionPointer;
        if (localPointer == uninitializedPointer)
            return true;
        return false;
    }
}
// ----
// testComparison() -> true
// testLocalAssignment() -> true
