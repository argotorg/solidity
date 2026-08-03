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
// Warning 3993: The BMC engine of the SMTChecker is deprecated and will be removed in a future release. Please use the CHC engine instead.
