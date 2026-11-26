contract A {
    uint public x = 7;
    modifier m { x = 2; _; }
}
contract C is A {
    modifier n { x = 1; _; }

    function f() public A.m returns (uint) {
        return 9;
    }
    function g() public n returns (uint) {
        return 10;
    }
}
// ----
// x() -> 7
// f() -> 9
// x() -> 2
// g() -> 0x0a
// x() -> 1
// f() -> 9
// x() -> 2
