contract C {
    struct S { uint x; uint[] y; }
    S constant x = S(5, new uint[](4));
}
// ----
