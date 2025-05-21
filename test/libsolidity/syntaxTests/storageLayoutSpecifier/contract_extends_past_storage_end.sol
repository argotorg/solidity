contract C layout at 2**256 - 2 {
    uint x;
    bool b;
}
// ----
// TypeError 5015: (21-31): Contract extends past the end of storage when this base slot value is specified.
