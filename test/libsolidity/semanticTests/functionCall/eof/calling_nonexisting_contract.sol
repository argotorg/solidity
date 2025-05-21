abstract contract D {
    function g() public virtual;
}


contract C {
    D d = D(address(0x1212));

    function f() public returns (uint256) {
        // This call throws on legacy bytecode because of calling nonexisting contract. Legacy checks that there is
        // a non-empty code under an address. EOF doesn't do it because non-observability assumption
        d.g();
        return 7;
    }

    function h() public returns (uint256) {
        address(d).call(""); // this does not throw (low-level)
        return 7;
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// f() -> 7
// h() -> 7
