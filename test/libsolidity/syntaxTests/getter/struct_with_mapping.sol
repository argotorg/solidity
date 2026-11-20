contract C {
    struct S {
        uint a;
        mapping(uint => uint) m;
    }
    S public s;
}
// ----
