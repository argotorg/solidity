abstract contract A {
    uint256 public s;
    modifier m() virtual;
    function f() public view m returns (uint256) { return s; }
}


// A.m has no body, so A.f only needs view. D implements m with a storage write.
contract D is A {
    modifier m() override { s = 5; _; }
}
// ----
// Warning 8429: (48-69): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 1614: (240-275): Modifier "m" has state mutability "nonpayable" in "D", but "A.f", which uses it, is declared "view".
