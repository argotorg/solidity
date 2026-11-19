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
    }
}
// ----
// s() -> 0x20, 0x07, 0x60, 0xa0, 0x03, 0x6162630000000000000000000000000000000000000000000000000000000000, 0x00
