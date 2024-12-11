library L1 {
    function foo() internal { new A(); }
}
library L2 {
    function foo() internal { L1.foo(); }
}
contract A {
    function f() public pure { type(L2).creationCode; }
}
// ====
// bytecodeFormat: legacy
// ----
// Warning 6133: (157-178): Statement has no effect.
