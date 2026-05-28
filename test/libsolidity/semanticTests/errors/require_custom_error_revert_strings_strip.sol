contract C {
    error MyError(uint errorCode, string errorMsg, bool flag);
    function flag() pure public returns (bool) { return false; }
    function f(int param) pure external {
        uint code = 8;
        string memory eMsg = "error";
        require(param % 2 == 0, MyError(code, eMsg, flag()));
    }
}
// ====
// revertStrings: strip
// ----
// f(int256): 3 -> FAILURE, hex"2ced9160", 8, 0x60, false, 5, "error"
// f(int256): 4 ->
