contract C {
    function f() public returns (bool) {
        // Random address, no contract deployed to it.
        (bool success, ) = address(0xffff).call("");
        return success;
    }
}
// ----
// f() -> true
