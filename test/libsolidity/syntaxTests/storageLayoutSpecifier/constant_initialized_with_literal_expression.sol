uint constant x = ((2**5 + 2**5) * (2 ** 10 + 1 << 1)) % 2**256 - 1;
contract C layout at x {}
// ----
