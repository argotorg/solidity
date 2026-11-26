contract A {
    modifier m() {
        f();
        _;
    }
    function f() internal virtual { revert("A"); }
}
contract B is A {
    function f() internal virtual override { revert("B"); }
}
contract C1 is B layout at 2**256 - 2**42 {
    function g() public m {}
    function f() internal virtual override { revert("C"); }
}
contract C2 is B {
    function g() public m {}
    function f() internal virtual override { revert("C"); }
}

contract F {
    function withSpecifier() public returns (string memory) {
        new C1().g();
    }
    function withoutSpecifier() public returns (string memory) {
        new C2().g();
    }
}
// ----
// withSpecifier() -> FAILURE, hex"08c379a0", 0x20, 1, "C"
// gas legacy: 54232
// gas legacy code: 45800
// withoutSpecifier() -> FAILURE, hex"08c379a0", 0x20, 1, "C"
// gas legacy: 54210
// gas legacy code: 45800
