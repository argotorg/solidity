contract C {
    function f() external returns (bool) {
        return this.f.address != address(0);
    }
    function g() external returns (bool) {
      return this.f.address == address(this);
    }
    function h(function() external a) public returns (address) {
      return a.address;
    }
}
// ====
// EVMVersion: >=prague
// bytecodeFormat: >=EOFv1
// ----
// f() -> true
// g() -> true
// h(function): left(0x1122334400112233445566778899AABBCCDDEEFF42424242) -> 0x1122334400112233445566778899AABBCCDDEEFF
