contract C {
    error MyError();
    function flag() pure public returns (bool) { return false; }
    function f(int param) pure external returns (int) {
        require(param % 2 == 0, MyError());
        return param / 2;
    }
}
// ====
// revertStrings: strip
// ----
// f(int256): 3 -> FAILURE, hex"dd6c951c"
// f(int256): 4 -> 2
