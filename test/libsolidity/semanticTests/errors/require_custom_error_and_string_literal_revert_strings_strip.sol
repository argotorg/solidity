contract C {
    error MyError(string message);
    function customError() pure external {
        require(false, MyError("Error"));
    }
    function stringLiteral() pure external {
        require(false, "Error");
    }
}
// ====
// revertStrings: strip
// ----
// customError() -> FAILURE, hex"8b3d2d43", 0x20, 5, "Error"
// stringLiteral() -> FAILURE
