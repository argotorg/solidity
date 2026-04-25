contract C {
    struct Profile {
        string name;
        uint256 age;
    }
    Profile constant PROF = Profile("alice", 30);

    function getName() public pure returns (string memory) { return PROF.name; }
    function getAge() public pure returns (uint256) { return PROF.age; }
}
// ====
// compileViaYul: true
// ----
// getName() -> 0x20, 5, "alice"
// getAge() -> 30
