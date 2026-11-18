==== Source: a.sol ====
contract A {
    function f() public pure virtual returns (uint256) { return 1; }
}

contract B is A {
    function f() public pure virtual override returns (uint256) { return super.f(); }
}
==== Source: b.sol ====
import "a.sol";

contract X {
    uint256 public s;
    function f() public virtual returns (uint256) { s = 5; return 100; }
}

contract D is A, X, B {
    function f() public pure override(A, X, B) returns (uint256) { return super.f(); }
}
// ----
// TypeError 7898: (a.sol:176-185): Function "B.f" declared as pure, but this "super" call resolves to a function with higher state mutability in a derived contract.
