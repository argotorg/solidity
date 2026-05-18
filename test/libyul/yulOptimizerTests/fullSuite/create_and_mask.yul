{
    // This does not optimize the masks away. Due to the way the expression simplifier
    // is built, it would have to create another `create` opcode for the simplification
    // which would be fatal.
    let a := and(create(0, 0, 0x20), 0xffffffffffffffffffffffffffffffffffffffff)
    let b := and(0xffffffffffffffffffffffffffffffffffffffff, create(0, 0, 0x20))
    sstore(a, b)
}
// ====
// EVMVersion: >=istanbul
// bytecodeFormat: legacy
// ----
// step: fullSuite
//
// {
//     {
//         let a := and(create(0, 0, 0x20), shr(96, not(0)))
//         sstore(a, and(shr(96, not(0)), create(0, 0, 0x20)))
//     }
// }
