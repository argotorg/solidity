contract C {
    error MyError(string message);
    function revertStatement() pure external {
        revert MyError("Error");
    }
}
// ====
// revertStrings: strip
// ----
// revertStatement() -> FAILURE, hex"8b3d2d43", 0x20, 5, "Error"
