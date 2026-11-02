contract A {
    modifier m virtual {
      _;
    }
}
contract C is A {
    function f() public A.m returns (uint) {
    }
}
// ====
// SMTEngine: all
// ----
// Warning 8429: (17-52): Virtual modifiers are deprecated and scheduled for removal.
