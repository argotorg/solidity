contract C {
    function() internal functionPointerSlotStart;
    int x;
    uint32 private y = 2;
    function() internal functionPointerSlotEnd;

    function testFunctionPointerSlotStart() public view returns (bool) {
        function() internal uninitializedPointer;
        if (functionPointerSlotStart == uninitializedPointer)
            return true;
        return false;
    }
    function testFunctionPointerSlotEnd() public view returns (bool) {
        function() internal uninitializedPointer;
        if (functionPointerSlotEnd == uninitializedPointer)
            return true;
        return false;
    }
}
// ----
// testFunctionPointerSlotStart() -> true
// testFunctionPointerSlotEnd() -> true
