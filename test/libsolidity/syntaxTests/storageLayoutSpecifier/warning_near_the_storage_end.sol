contract A layout at 2**256 - 2**64 {}
contract C layout at 2**256 - 2**65 {
    uint[2**63] x;
    uint[2**63] y;
}
// ----
// Warning 3495: (11-35): This contract is very close to the end of storage. This limits its future upgradability.
// Warning 3495: (50-74): This contract is very close to the end of storage. This limits its future upgradability.
