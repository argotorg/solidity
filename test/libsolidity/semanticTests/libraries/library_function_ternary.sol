library L {
    struct S { uint x; }
    function pure_sum(S storage s, uint v) public view returns (uint) { return s.x + v; }
    function sum(S storage s, uint v) external returns (uint) { s.x += v; return s.x; }
}
contract C {
    L.S s;
    function f(bool b, uint v) public returns (uint) {
        return (b ? L.pure_sum : L.sum)(s, v);
    }
}
// ====
// EVMVersion: >=byzantium
// ----
// library: L
// f(bool,uint256): false, 7 -> 7
// f(bool,uint256): true, 7 -> 14
