contract C layout at 1 {
    uint[2**256 - 1] x;
    uint y;
}
// ----
// TypeError 7676: (0-62): Contract requires too much storage.
