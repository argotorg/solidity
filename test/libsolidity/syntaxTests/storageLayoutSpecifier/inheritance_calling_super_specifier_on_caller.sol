contract A { function f() public virtual {} }
contract B1 is A layout at 2**256 - 2**42 { function f() public override virtual { super.f(); } }
contract B2 is A { function f() public override virtual { super.f(); } }
// ----
// Warning 3495: (63-87): This contract is very close to the end of storage. This limits its future upgradability.
