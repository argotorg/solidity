{
    sstore(
        0xffffffffffffffffffffffffffffffffffffffff,
        memoryguard(0xffffffffffffffffffffffffffffffffffffffff)
    )
}
// ====
// EVMVersion: >=constantinople
// ----
// step: constantOptimiser
//
// {
//     sstore(sub(shl(160, 1), 1), memoryguard(0xffffffffffffffffffffffffffffffffffffffff))
// }
