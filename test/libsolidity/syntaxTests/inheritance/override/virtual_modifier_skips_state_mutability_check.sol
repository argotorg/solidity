contract A {
    uint256 public s;
    modifier m() virtual { _; }
    function f() public pure m returns (uint256) { return 1; }
}


// A.f is checked as pure against A.m, but in D the modifier resolves to D.m,
// which writes storage.
contract D is A {
    modifier m() override { s = 5; _; }
}
// ----
// Warning 8429: (39-66): Virtual modifiers are deprecated and scheduled for removal.
// TypeError 1614: (259-294): This modifier overrides "m" with state mutability "nonpayable", but "A.f", which uses it, is declared "pure".
