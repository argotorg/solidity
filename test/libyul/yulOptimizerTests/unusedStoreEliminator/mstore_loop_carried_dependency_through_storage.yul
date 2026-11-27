// mstore(v, 0xAA) must NOT be eliminated: the next iteration reads it back through w,
// with the pointer carried across iterations through storage, not through a Yul variable.
{
    sstore(0, 64)
    for { let i := 0 } lt(i, 2) { i := add(i, 1) } {
        let v := sload(0)
        let w := add(v, 32)
        mstore(v, 0xAA)
        sstore(0, sub(v, 32))
        sstore(1, mload(w))
    }
}
// ----
// step: unusedStoreEliminator
//
// {
//     {
//         sstore(0, 64)
//         let i := 0
//         let i_12 := i
//         for { }
//         lt(i, 2)
//         {
//             let i_15 := i
//             i := add(i_15, 1)
//             let i_13 := i
//         }
//         {
//             let i_14 := i
//             let v := sload(0)
//             let w := add(v, 32)
//             mstore(v, 0xAA)
//             sstore(0, sub(v, 32))
//             sstore(1, mload(w))
//         }
//     }
// }
