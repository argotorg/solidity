contract C {
    string[3] constant NAMES = ["alice", "bob", "charlie"];

    function get0() public pure returns (string memory) { return NAMES[0]; }
    function get1() public pure returns (string memory) { return NAMES[1]; }
    function get2() public pure returns (string memory) { return NAMES[2]; }
}
// ====
// compileViaYul: true
// ----
// get0() -> 0x20, 5, "alice"
// get1() -> 0x20, 3, "bob"
// get2() -> 0x20, 7, "charlie"
