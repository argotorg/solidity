contract C {
    function f() public view returns (address) { return address(this); }
    function g() public view returns (uint) { return f().balance; }
    function h() public pure returns (bytes memory) { return msg.data; }
    function j() public pure returns (uint) { return h().length; }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
