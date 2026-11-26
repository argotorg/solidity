contract C {
    struct T {
        mapping(uint => uint) m;
    }
    struct S {
        uint a;
        T t;
    }
    S public s;
}
// ----
// TypeError 6744: (121-131): Internal or recursive type is not allowed for public state variables.
