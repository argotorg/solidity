contract C {
    function f() public pure returns (bytes memory) {
        return bytes.concat(hex"", unicode"", "");
    }
}
// ----
