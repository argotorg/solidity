contract C {
    function f() public view returns (address a1, address a2) {
        a1 = C(address(0x1234)).f.address;
        C(address(0x1234)).f.address;
        [C(address(0x1234)).f.address][0];
        a2 = [C(address(0x1234)).f.address][0];
    }
}
// ----
// f() -> 0x1234, 0x1234
