contract C {
    struct S {
        uint a;
        bytes b;
        uint[] d;
    }
    uint shifter;
    S public s;
    constructor() {
        s.a = 7;
        s.b = "abc";
        s.d.push(10);
    }
}
// ----
// s() -> 0x20, 7, 0x60, 0xa0, 3, 0x6162630000000000000000000000000000000000000000000000000000000000, 1, 10
