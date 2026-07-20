contract A layout at 2**256 - 2**64 {}

contract B {
    uint baseVar;
}
contract C is B layout at 2**256 - 3 {
    uint x;
    uint constant CONST_VAR = 2;
    int immutable immutableVar = 3;
}
// ----
// Warning 3495: (11-35): This contract is very close to the end of storage. This limits its future upgradability.
// Warning 3495: (89-109): This contract is very close to the end of storage. This limits its future upgradability.
