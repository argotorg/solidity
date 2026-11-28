struct R {
    R[] a;
    uint[2**255] b;
    uint[2**255] c;
}
contract C {
    R[] d;
}
// ----
// TypeError 1534: (81-86): Type too large for storage.
