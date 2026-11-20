library L {
    function f() external returns (uint) { return 0; }
    function g() public view returns (uint) { return 1; }
    function h() external pure returns (uint) { return 2; }
}

contract C {
    function test(bool b1, bool b2) public returns (uint) {
        return (b1 ? L.f : (b2 ? L.g : L.h))();
    }
}
// ----
// library: L
// test(bool,bool): true, true -> 0
// test(bool,bool): true, false -> 0
// test(bool,bool): false, true -> 1
// test(bool,bool): false, false -> 2
