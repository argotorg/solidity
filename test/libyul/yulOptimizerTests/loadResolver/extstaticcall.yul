{
    let a := 0
    let b := 1
    let c := 2
    sstore(a, b)
    mstore(900, 7)
    let d := extstaticcall(10, 0, 200)
    sstore(add(a, 1), mload(900))
    // Main test objective: replace this sload.
    mstore(0, sload(a))
}
// ====
// EVMVersion: >=byzantium
// bytecodeFormat: >=EOFv1
// ----
// step: loadResolver
//
// {
//     {
//         let a := 0
//         let b := 1
//         sstore(a, b)
//         let _1 := 7
//         mstore(900, _1)
//         pop(extstaticcall(10, a, 200))
//         sstore(1, _1)
//         mstore(a, b)
//     }
// }
