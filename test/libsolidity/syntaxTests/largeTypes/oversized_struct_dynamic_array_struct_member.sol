struct S {
    uint[2**255] a;
    uint[2**255] b;
}
struct T {
    S[] d;
}
contract C {
    T t;
}
// ----
// TypeError 1534: (94-97): Type too large for storage.
