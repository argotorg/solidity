interface I {
    function s() external view returns (uint);
}

contract C is I {
    struct S {
        uint a;
        mapping(uint => uint) m;
    }
    S public override s;
}
// ----
