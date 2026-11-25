struct R {
    R[] a;
    uint x;
}
contract C {
    function f() public pure {
        R memory r;
        R[] memory d;
        r; d;
    }
}
// ----
