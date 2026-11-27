{
    let x := 1000
    let i := 0
    // mstore(x, 7) in iteration k is read by mload in iteration k + 2,
    // so it must not be removed.
    for { } lt(i, 3) { mstore(x, 7) i := add(i, 1) } {
        sstore(i, mload(add(x, 64)))
        x := sub(x, 64)
    }
}
// ----
// step: unusedStoreEliminator
//
// {
//     {
//         let x := 1000
//         let x_7 := x
//         let i := 0
//         let i_8 := i
//         for { }
//         lt(i, 3)
//         {
//             let x_13 := x
//             let i_14 := i
//             mstore(x_13, 7)
//             i := add(i_14, 1)
//             let i_9 := i
//         }
//         {
//             let x_11 := x
//             let i_12 := i
//             sstore(i_12, mload(add(x_11, 64)))
//             x := sub(x_11, 64)
//             let x_10 := x
//         }
//     }
// }
