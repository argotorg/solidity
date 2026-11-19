contract C {
    struct S {
        uint a;
        mapping(uint => uint) m;
    }
    S public s;
}
// ----
// TypeError 6744: (87-97): Internal or recursive type is not allowed for public state variables.
