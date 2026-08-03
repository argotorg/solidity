contract A { function f() public virtual {} }
contract B is A { function f() public override virtual { super.f(); } }
contract C1 is B layout at 2**256 - 2**42 {}
contract C2 is B {}
// ----
// Warning 3495: (135-159): This contract is very close to the end of storage. This limits its future upgradability.
